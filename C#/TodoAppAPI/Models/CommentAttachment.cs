namespace TodoAppAPI.Models
{
    public class CommentAttachment
    {
        public string AttachmentUId { get; set; } = Guid.NewGuid().ToString();
        public string Url { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public string CommentUId { get; set; } = string.Empty;
        public Comment? Comment { get; set; }
    }
}
