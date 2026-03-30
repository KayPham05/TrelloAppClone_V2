using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class CommentService : ICommentService
    {
        private readonly TodoDbContext _dbContext;

        public CommentService(TodoDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<List<Comment>> GetCommentsByCardAsync(string cardUId)
        {
            return await _dbContext.Comments
                .Where(c => c.CardUId == cardUId)
                .Include(c => c.User) // lấy thông tin người comment
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

                return await _dbContext.Comments
                    .Include(c => c.User)
                    .FirstOrDefaultAsync(c => c.CommentUId == comment.CommentUId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm comment: {ex.Message}");
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
                Console.WriteLine($"Lỗi khi cập nhật comment: {ex.Message}");
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
                Console.WriteLine($"Lỗi khi xóa comment: {ex.Message}");
                return false;
            }
        }
    }
}
