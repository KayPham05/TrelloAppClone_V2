using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class CommentService : ICommentService
    {
        private static readonly Regex MentionRegex = new(
            @"@([A-Za-z0-9._%+\-]+(?:@[A-Za-z0-9.\-]+\.[A-Za-z]{2,})?)",
            RegexOptions.Compiled);

        private readonly TodoDbContext _dbContext;
        private readonly INotificationService _notificationService;

        public CommentService(TodoDbContext dbContext, INotificationService notificationService)
        {
            _dbContext = dbContext;
            _notificationService = notificationService;
        }

        public async Task<List<Comment>> GetCommentsByCardAsync(string cardUId)
        {
            return await _dbContext.Comments
                .Where(c => c.CardUId == cardUId)
                .Include(c => c.User)
                .Include(c => c.Attachments)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();
        }

        public async Task<Comment?> GetByIdAsync(string commentUId)
        {
            return await _dbContext.Comments
                .Include(c => c.User)
                .Include(c => c.Attachments)
                .FirstOrDefaultAsync(c => c.CommentUId == commentUId);
        }

        public async Task<Comment?> AddCommentAsync(Comment comment)
        {
            try
            {
                comment.CommentUId = Guid.NewGuid().ToString();
                comment.CreatedAt = DateTime.UtcNow;

                await _dbContext.Comments.AddAsync(comment);
                await _dbContext.SaveChangesAsync();

                await CreateMentionNotificationsAsync(comment);
                await CreateCommentNotificationsAsync(comment);

                return await GetByIdAsync(comment.CommentUId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding comment: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> UpdateCommentAsync(Comment comment)
        {
            try
            {
                var existing = await _dbContext.Comments.FindAsync(comment.CommentUId);
                if (existing == null) return false;

                existing.Content = comment.Content;
                existing.UpdatedAt = DateTime.UtcNow;
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating comment: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteCommentAsync(string commentUId)
        {
            try
            {
                var comment = await _dbContext.Comments.FindAsync(commentUId);
                if (comment == null) return false;

                _dbContext.Comments.Remove(comment);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting comment: {ex.Message}");
                return false;
            }
        }

        public async Task<CommentAttachment?> AddAttachmentAsync(
            string commentUId,
            string url,
            string fileName,
            string userUId,
            string? description = null)
        {
            try
            {
                var comment = await _dbContext.Comments
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.CommentUId == commentUId);
                if (comment == null || comment.UserUId != userUId)
                    return null;

                var attachment = new CommentAttachment
                {
                    AttachmentUId = Guid.NewGuid().ToString(),
                    CommentUId = commentUId,
                    Url = url,
                    FileName = fileName,
                    Description = description,
                    CreatedAt = DateTime.UtcNow
                };

                _dbContext.CommentAttachments.Add(attachment);
                await _dbContext.SaveChangesAsync();
                return attachment;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding comment attachment: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> RemoveAttachmentAsync(string attachmentUId, string userUId)
        {
            try
            {
                var attachment = await _dbContext.CommentAttachments
                    .Include(a => a.Comment)
                    .FirstOrDefaultAsync(a => a.AttachmentUId == attachmentUId);
                if (attachment == null || attachment.Comment?.UserUId != userUId)
                    return false;

                _dbContext.CommentAttachments.Remove(attachment);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error removing comment attachment: {ex.Message}");
                return false;
            }
        }

        private async Task CreateMentionNotificationsAsync(Comment comment)
        {
            if (string.IsNullOrWhiteSpace(comment.UserUId))
                return;

            var mentionedTokens = MentionRegex.Matches(comment.Content ?? string.Empty)
                .Select(m => m.Groups[1].Value)
                .Where(token => !string.IsNullOrWhiteSpace(token))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            if (mentionedTokens.Count == 0)
                return;

            var card = await LoadCardForNotificationsAsync(comment.CardUId);
            if (card == null)
                return;

            var memberIds = await GetMentionableMemberIdsAsync(card);
            if (memberIds.Count == 0)
                return;

            var users = await _dbContext.Users
                .AsNoTracking()
                .Where(u => memberIds.Contains(u.UserUId))
                .ToListAsync();

            var actorName = await GetUserDisplayNameAsync(comment.UserUId);
            var cardTitle = card.Title ?? card.CardUId;

            var recipients = users
                .Where(u => u.UserUId != comment.UserUId)
                .Where(u => mentionedTokens.Any(token => MatchesMentionToken(u, token)))
                .Select(u => u.UserUId)
                .Distinct()
                .Select(userId => new NotificationDTO
                {
                    RecipientId = userId,
                    ActorId = comment.UserUId,
                    Type = NotificationType.Mention,
                    Title = "Bạn đã được nhắc đến trong thẻ",
                    Message = $"{actorName} đã nhắc đến bạn trong {cardTitle}.",
                    BoardId = card.List?.BoardUId,
                    ListId = card.ListUId,
                    CardId = card.CardUId,
                    Link = $"/card-detail/{card.CardUId}"
                })
                .ToList();

            await _notificationService.TryCreateManyInternalAsync(recipients, "comment mention");
        }

        private async Task CreateCommentNotificationsAsync(Comment comment)
        {
            if (string.IsNullOrWhiteSpace(comment.UserUId))
                return;

            var card = await LoadCardForNotificationsAsync(comment.CardUId);
            if (card == null)
                return;

            var memberIds = card.CardMembers?
                .Select(cm => cm.UserUId)
                .Where(userId => userId != comment.UserUId)
                .Distinct()
                .ToList() ?? new List<string>();

            if (memberIds.Count == 0)
                return;

            var actorName = await GetUserDisplayNameAsync(comment.UserUId);
            var cardTitle = card.Title ?? card.CardUId;

            var notifications = memberIds.Select(userId => new NotificationDTO
            {
                RecipientId = userId,
                ActorId = comment.UserUId,
                Type = NotificationType.Comment,
                Title = "Có bình luận mới trong thẻ",
                Message = $"{actorName} đã bình luận trong {cardTitle}.",
                BoardId = card.List?.BoardUId,
                ListId = card.ListUId,
                CardId = card.CardUId,
                Link = $"/card-detail/{card.CardUId}"
            }).ToList();

            await _notificationService.TryCreateManyInternalAsync(notifications, "comment add");
        }

        private async Task<Card?> LoadCardForNotificationsAsync(string cardUId)
        {
            return await _dbContext.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.CardMembers)
                .FirstOrDefaultAsync(c => c.CardUId == cardUId);
        }

        private async Task<List<string>> GetMentionableMemberIdsAsync(Card card)
        {
            var memberIds = card.CardMembers?
                .Select(cm => cm.UserUId)
                .Distinct()
                .ToList() ?? new List<string>();

            var boardId = card.List?.BoardUId;
            if (!string.IsNullOrWhiteSpace(boardId))
            {
                var boardMemberIds = await _dbContext.BoardMembers
                    .AsNoTracking()
                    .Where(bm => bm.BoardUId == boardId)
                    .Select(bm => bm.UserUId)
                    .ToListAsync();
                memberIds.AddRange(boardMemberIds);
            }

            return memberIds
                .Where(id => !string.IsNullOrWhiteSpace(id))
                .Distinct()
                .ToList();
        }

        private static bool MatchesMentionToken(User user, string token)
        {
            return string.Equals(user.UserName, token, StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(user.Email, token, StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(GetEmailPrefix(user.Email), token, StringComparison.OrdinalIgnoreCase);
        }

        private static string GetEmailPrefix(string email)
        {
            var atIndex = email.IndexOf('@');
            return atIndex > 0 ? email[..atIndex] : email;
        }

        private async Task<string> GetUserDisplayNameAsync(string userUId)
        {
            var name = await _dbContext.Users
                .AsNoTracking()
                .Where(u => u.UserUId == userUId)
                .Select(u => u.UserName)
                .FirstOrDefaultAsync();

            return string.IsNullOrWhiteSpace(name) ? userUId : name;
        }
    }
}
