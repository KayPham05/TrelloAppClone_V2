namespace TodoAppAPI.DTOs.Comments
{
    public sealed class CommentAttachmentResponseDto
    {
        public string AttachmentUId { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
