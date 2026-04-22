namespace TodoAppAPI.DTOs
{
    public class CardDTO
    {
        public string CardUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime? DueDate { get; set; }
        public int Position { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? BackgroundUrl { get; set; }

        public string? ListUId { get; set; }
    }
}
