namespace TodoAppAPI.Models
{
    public class Notification
    {
        public string NotiId { get; set; } = Guid.NewGuid().ToString();

        // Người nhận thông báo
        public string RecipientId { get; set; } = default!;
        public User Recipient { get; set; } = default!;

        // Người gửi thông báo
        public string? ActorId { get; set; }
        public User? Actor { get; set; }

        // Loại thông báo
        public NotificationType Type { get; set; }

        // Nội dung
        public string Title { get; set; } = default!;
        public string Message { get; set; } = default!;
        public string? Link { get; set; }

        // Liên kết đến các thực thể liên quan (nếu có)
        public string? WorkspaceId { get; set; }
        public string? BoardId { get; set; }
        public string? ListId { get; set; }
        public string? CardId { get; set; }

        // Trạng thái
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public bool Read { get; set; } = false;
        public DateTime? ReadAt { get; set; }
    }
}
