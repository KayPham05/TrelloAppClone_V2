namespace TodoAppAPI.DTOs
{
    public class TodoItemDTO
    {
        public string TodoItemUId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public bool IsCompleted { get; set; }
        public DateTime CreatedAt { get; set; }
        public string CardUId { get; set; } = string.Empty;
    }
}
