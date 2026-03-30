using TodoAppAPI.Models;

namespace TodoAppAPI.DTOs
{
    public class NotificationDTO
    {
        public string RecipientId { get; set; } = default!;
        public string? ActorId { get; set; } = default!;
        public NotificationType Type { get; set; }

        public string Title { get; set; } = default!;
        public string Message { get; set; } = default!;
        public string? Link { get; set; }

        public string? WorkspaceId { get; set; }
        public string? BoardId { get; set; }
        public string? ListId { get; set; }
        public string? CardId { get; set; }
    }
}
