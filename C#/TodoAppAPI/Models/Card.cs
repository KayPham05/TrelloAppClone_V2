namespace TodoAppAPI.Models
{
    public class Card
    {
        public string CardUId { get; set; } = Guid.NewGuid().ToString();
        public string? Title { get; set; }
        public string? Description { get; set; }
        public DateTime? DueDate { get; set; }
        public int Position { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string? Status { get; set; }
        public string? BackgroundUrl { get; set; }
        public string UserUId { get; set; } = string.Empty;

        // FK - List (nullable for inbox cards)
        public string? ListUId { get; set; } // ← Changed to nullable, removed default value

        public List? List { get; set; }

        // Navigation Properties
        public ICollection<Activity>? Activities { get; set; }
        public ICollection<TodoItem>? TodoItems { get; set; }
        public ICollection<Comment>? Comments { get; set; }
        public ICollection<UserInboxCard>? UserInboxCards { get; set; } // ← Changed to nullable
        public virtual ICollection<CardMember>? CardMembers { get; set; }
        public virtual ICollection<FileUrl>? FileUrls { get; set; }
        public virtual ICollection<CardLabel>? CardLabels { get; set; }
    }
}
