using TodoAppAPI.Models;

namespace TodoAppAPI.DTOs.Comments
{
    public sealed class CommentResponseDto
    {
        public string CommentUId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string CardUId { get; set; } = string.Empty;
        public string? UserUId { get; set; }
        public User? User { get; set; }
        public List<CommentAttachmentResponseDto> Attachments { get; set; } = new();

        public static CommentResponseDto FromEntity(Comment comment)
        {
            return new CommentResponseDto
            {
                CommentUId = comment.CommentUId,
                Content = comment.Content,
                CreatedAt = comment.CreatedAt,
                UpdatedAt = comment.UpdatedAt,
                CardUId = comment.CardUId,
                UserUId = comment.UserUId,
                User = comment.User,
                Attachments = comment.Attachments
                    .OrderByDescending(a => a.CreatedAt)
                    .Select(a => new CommentAttachmentResponseDto
                    {
                        AttachmentUId = a.AttachmentUId,
                        Url = a.Url,
                        FileName = a.FileName,
                        Description = a.Description,
                        CreatedAt = a.CreatedAt
                    })
                    .ToList()
            };
        }
    }
}
