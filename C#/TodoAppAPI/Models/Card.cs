namespace TodoAppAPI.Models
{
    public class Card
    {
        public string CardUId { get; set; } = Guid.NewGuid().ToString();
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime? DueDate { get; set; }
        public int Position { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string Status { get; set; } = "To Do";

        // FK - List (nullable for inbox cards)
        public string? ListUId { get; set; } // ← Changed to nullable, removed default value

        public List? List { get; set; }

        // Navigation Properties
        public ICollection<Activity>? Activities { get; set; }
        public ICollection<TodoItem>? TodoItems { get; set; }
        public ICollection<Comment>? Comments { get; set; }
        public ICollection<UserInboxCard>? UserInboxCards { get; set; } // ← Changed to nullable
        public virtual ICollection<CardMember>? CardMembers { get; set; }
    }
}
