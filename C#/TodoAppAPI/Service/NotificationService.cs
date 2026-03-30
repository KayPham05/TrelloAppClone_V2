using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class NotificationService : INotificationService
    {
        private readonly TodoDbContext _context;

        public NotificationService(TodoDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Notification>> GetNotificationsAsync(string userId, int page, int pageSize)
        {
            return await _context.Notifications
                .Include(n => n.Actor)
                .Where(n => n.RecipientId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<bool> MarkAsReadAsync(string notiId)
        {
            var noti = await _context.Notifications.FindAsync(notiId);
            if (noti == null) return false;

            noti.Read = true;
            noti.ReadAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> MarkAllAsReadAsync(string userId)
        {
            var count = await _context.Notifications
        .Where(n => n.RecipientId == userId && !n.Read)
        .ExecuteUpdateAsync(setter => setter
            .SetProperty(n => n.Read, true)
            .SetProperty(n => n.ReadAt, DateTime.Now));
            return count;
        }

        public async Task<Notification> CreateAsync(NotificationDTO dto)
        {
            try
            {
                // Kiểm tra người nhận có tồn tại không
                var recipientExists = await _context.Users
                    .AnyAsync(u => u.UserUId == dto.RecipientId);
                if (!recipientExists)
                {
                    Console.WriteLine($"[ERROR] Recipient not found: {dto.RecipientId}");
                    return null;
                }

                // Kiểm tra actor (nếu có)
                if (!string.IsNullOrEmpty(dto.ActorId))
                {
                    var actorExists = await _context.Users
                        .AnyAsync(u => u.UserUId == dto.ActorId);
                    if (!actorExists)
                    {
                        Console.WriteLine($"[WARN] Actor not found: {dto.ActorId}");
                        dto.ActorId = null;
                    }
                }

                // Tạo đối tượng Notification
                var noti = new Notification
                {
                    NotiId = Guid.NewGuid().ToString(),
                    RecipientId = dto.RecipientId,
                    ActorId = dto.ActorId,
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
                };

                _context.Notifications.Add(noti);
                await _context.SaveChangesAsync();

                return noti;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] Failed to create notification: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> DeleteAsync(string notiId)
        {
            if (string.IsNullOrWhiteSpace(notiId))
                return false;

            var noti = await _context.Notifications
                .AsNoTracking()
                .FirstOrDefaultAsync(n => n.NotiId == notiId);

            if (noti == null)
            {
                Console.WriteLine($"[WARN] Notification not found for deletion: {notiId}");
                return false;
            }

            _context.Notifications.Remove(new Notification { NotiId = notiId });
            await _context.SaveChangesAsync();

            return true;
        }

    }
}
