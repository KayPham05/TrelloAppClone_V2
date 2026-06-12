using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class NotificationService : INotificationService
    {
        private static readonly HashSet<NotificationType> SentToMeTypes = new()
        {
            NotificationType.Assign,
            NotificationType.CardUnassigned,
            NotificationType.Mention,
            NotificationType.BoardMemberAdded,
            NotificationType.BoardMemberRemoved,
            NotificationType.BoardRoleChanged,
            NotificationType.WorkspaceMemberAdded,
            NotificationType.WorkspaceMemberRemoved,
            NotificationType.WorkspaceRoleChanged,
            NotificationType.Move,
            NotificationType.DueDateChanged,
            NotificationType.DueDateReminder,
            NotificationType.CardArchived,
            NotificationType.AttachmentAdded,
            NotificationType.AttachmentRemoved,
            NotificationType.CardRenamed
        };

        private readonly TodoDbContext _context;
        private readonly IHubContext<NotificationHub> _hubContext;

        public NotificationService(TodoDbContext context, IHubContext<NotificationHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        public async Task<NotificationPageDto> GetNotificationsAsync(
            string userId,
            NotificationTab tab,
            int page,
            int pageSize)
        {
            page = Math.Max(page, 1);
            pageSize = Math.Clamp(pageSize, 1, 50);

            var query = _context.Notifications
                .AsNoTracking()
                .Include(n => n.Actor)
                .Where(n => n.RecipientId == userId);

            query = tab switch
            {
                NotificationTab.SentToMe => query.Where(n => SentToMeTypes.Contains(n.Type) && !n.Read),
                NotificationTab.Unread => query.Where(n => !n.Read),
                NotificationTab.Read => query.Where(n => n.Read),
                _ => query
            };

            var items = await query
                .OrderByDescending(n => n.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize + 1)
                .ToListAsync();

            var unreadCount = await GetUnreadCountAsync(userId);
            var hasMore = items.Count > pageSize;

            return new NotificationPageDto
            {
                Items = items.Take(pageSize).Select(ToResponseDto).ToList(),
                UnreadCount = unreadCount,
                HasMore = hasMore
            };
        }

        public async Task<int> GetUnreadCountAsync(string userId)
        {
            return await _context.Notifications.CountAsync(n => n.RecipientId == userId && !n.Read);
        }

        public async Task<bool> MarkAsReadAsync(string userId, string notiId)
        {
            var noti = await _context.Notifications.FirstOrDefaultAsync(n => n.NotiId == notiId);
            if (noti == null || noti.RecipientId != userId) return false;
            if (!noti.Read)
            {
                noti.Read = true;
                noti.ReadAt = DateTime.Now;
                await _context.SaveChangesAsync();
            }

            await BroadcastUnreadCountAsync(userId);
            await _hubContext.Clients
                .Group(NotificationHub.UserGroup(userId))
                .SendAsync("NotificationRead", noti.NotiId);

            return true;
        }

        public async Task<int> MarkAllAsReadAsync(string userId)
        {
            var now = DateTime.Now;
            var count = await _context.Notifications
                .Where(n => n.RecipientId == userId && !n.Read)
                .ExecuteUpdateAsync(setter => setter
                    .SetProperty(n => n.Read, true)
                    .SetProperty(n => n.ReadAt, now));

            await BroadcastUnreadCountAsync(userId);
            await _hubContext.Clients
                .Group(NotificationHub.UserGroup(userId))
                .SendAsync("NotificationReadAll");

            return count;
        }

        public async Task<Notification?> CreateInternalAsync(NotificationDTO dto)
        {
            var created = await CreateManyInternalAsync(new[] { dto });
            return created.FirstOrDefault();
        }

        public async Task<IReadOnlyList<Notification>> CreateManyInternalAsync(IEnumerable<NotificationDTO> dtos)
        {
            var result = new List<Notification>();
            foreach (var dto in dtos)
            {
                if (string.IsNullOrWhiteSpace(dto.RecipientId))
                    continue;

                if (!await _context.Users.AnyAsync(u => u.UserUId == dto.RecipientId))
                    continue;

                var actorId = dto.ActorId;
                if (!string.IsNullOrWhiteSpace(actorId) &&
                    !await _context.Users.AnyAsync(u => u.UserUId == actorId))
                {
                    actorId = null;
                }

                result.Add(new Notification
                {
                    NotiId = Guid.NewGuid().ToString(),
                    RecipientId = dto.RecipientId,
                    ActorId = actorId,
                    Type = dto.Type,
                    Title = dto.Title,
                    Message = dto.Message,
                    Link = dto.Link,
                    WorkspaceId = dto.WorkspaceId,
                    BoardId = dto.BoardId,
                    ListId = dto.ListId,
                    CardId = dto.CardId,
                    CreatedAt = DateTime.Now,
                    Read = false
                });
            }

            if (result.Count == 0)
                return result;

            _context.Notifications.AddRange(result);
            await _context.SaveChangesAsync();

            var actorIds = result
                .Select(n => n.ActorId)
                .Where(id => !string.IsNullOrWhiteSpace(id))
                .Distinct()
                .ToList();
            var actorNames = await _context.Users
                .AsNoTracking()
                .Where(u => actorIds.Contains(u.UserUId))
                .ToDictionaryAsync(u => u.UserUId, u => u.UserName);

            foreach (var notification in result)
            {
                var response = ToResponseDto(notification);
                if (!string.IsNullOrWhiteSpace(notification.ActorId) &&
                    actorNames.TryGetValue(notification.ActorId, out var actorName))
                {
                    response.ActorName = actorName;
                }

                try
                {
                    await _hubContext.Clients
                        .Group(NotificationHub.UserGroup(notification.RecipientId))
                        .SendAsync("NotificationCreated", response);
                    await BroadcastUnreadCountAsync(notification.RecipientId);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Notification realtime broadcast failed for {notification.NotiId}: {ex.Message}");
                }
            }

            return result;
        }

        public async Task<bool> DeleteAsync(string userId, string notiId)
        {
            if (string.IsNullOrWhiteSpace(notiId))
                return false;

            var noti = await _context.Notifications
                .FirstOrDefaultAsync(n => n.NotiId == notiId && n.RecipientId == userId);

            if (noti == null)
                return false;

            _context.Notifications.Remove(noti);
            await _context.SaveChangesAsync();

            await _hubContext.Clients
                .Group(NotificationHub.UserGroup(userId))
                .SendAsync("NotificationDeleted", notiId);
            await BroadcastUnreadCountAsync(userId);

            return true;
        }

        private async Task BroadcastUnreadCountAsync(string userId)
        {
            var unreadCount = await GetUnreadCountAsync(userId);
            await _hubContext.Clients
                .Group(NotificationHub.UserGroup(userId))
                .SendAsync("UnreadCountChanged", unreadCount);
        }

        private static NotificationResponseDto ToResponseDto(Notification noti)
        {
            return new NotificationResponseDto
            {
                NotiId = noti.NotiId,
                RecipientId = noti.RecipientId,
                ActorId = noti.ActorId,
                ActorName = noti.Actor?.UserName,
                Type = noti.Type,
                Title = noti.Title,
                Message = noti.Message,
                Link = noti.Link,
                WorkspaceId = noti.WorkspaceId,
                BoardId = noti.BoardId,
                ListId = noti.ListId,
                CardId = noti.CardId,
                CreatedAt = noti.CreatedAt,
                Read = noti.Read,
                ReadAt = noti.ReadAt
            };
        }
    }
}
