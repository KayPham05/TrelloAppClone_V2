using TodoAppAPI.Models;

namespace TodoAppAPI.DTOs
{
    public enum NotificationTab
    {
        All,
        SentToMe,
        Unread,
        Read
    }

    public class NotificationResponseDto
    {
        public string NotiId { get; set; } = string.Empty;
        public string RecipientId { get; set; } = string.Empty;
        public string? ActorId { get; set; }
        public string? ActorName { get; set; }
        public NotificationType Type { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? Link { get; set; }
        public string? WorkspaceId { get; set; }
        public string? BoardId { get; set; }
        public string? ListId { get; set; }
        public string? CardId { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool Read { get; set; }
        public DateTime? ReadAt { get; set; }
    }

    public class NotificationPageDto
    {
        public List<NotificationResponseDto> Items { get; set; } = new();
        public int UnreadCount { get; set; }
        public bool HasMore { get; set; }
    }
}
