using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface ICommentService
    {
        Task<List<Comment>> GetCommentsByCardAsync(string cardUId);

        Task<Comment?> GetByIdAsync(string commentUId);

        Task<Comment?> AddCommentAsync(Comment comment);

        Task<bool> DeleteCommentAsync(string commentUId);

        Task<bool> UpdateCommentAsync(Comment comment);

        Task<CommentAttachment?> AddAttachmentAsync(string commentUId, string url, string fileName, string userUId, string? description = null);

        Task<bool> RemoveAttachmentAsync(string attachmentUId, string userUId);
    }
}
