namespace TodoAppAPI.Models
{
    public class TodoItem
    {
        public string TodoItemUId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public bool IsCompleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string CardUId { get; set; } = string.Empty;
        public Card? Card { get; set; }
    }
}
