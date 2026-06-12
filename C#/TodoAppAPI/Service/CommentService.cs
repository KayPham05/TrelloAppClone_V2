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
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();
        }

        public async Task<Comment?> GetByIdAsync(string commentUId)
        {
            return await _dbContext.Comments
                .Include(c => c.User)
                .FirstOrDefaultAsync(c => c.CommentUId == commentUId);
        }

        public async Task<Comment?> AddCommentAsync(Comment comment)
        {
            try
            {
                comment.CommentUId = Guid.NewGuid().ToString();
                comment.CreatedAt = DateTime.Now;

                await _dbContext.Comments.AddAsync(comment);
                await _dbContext.SaveChangesAsync();
                await CreateMentionNotificationsAsync(comment);

                return await _dbContext.Comments
                    .Include(c => c.User)
                    .FirstOrDefaultAsync(c => c.CommentUId == comment.CommentUId);
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

        private async Task CreateMentionNotificationsAsync(Comment comment)
        {
            var mentionedTokens = Regex.Matches(comment.Content ?? string.Empty, @"@([A-Za-z0-9._-]+)")
                .Select(m => m.Groups[1].Value)
                .Where(token => !string.IsNullOrWhiteSpace(token))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            if (mentionedTokens.Count == 0)
                return;

            var card = await _dbContext.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.CardMembers)
                .FirstOrDefaultAsync(c => c.CardUId == comment.CardUId);

            if (card == null)
                return;

            var memberIds = card.CardMembers?
                .Select(cm => cm.UserUId)
                .Distinct()
                .ToList() ?? new List<string>();

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
                .Where(u => mentionedTokens.Any(token =>
                    string.Equals(u.UserName, token, StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(GetEmailPrefix(u.Email), token, StringComparison.OrdinalIgnoreCase)))
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
