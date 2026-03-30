namespace TodoAppAPI.DTOs
{
    public class ListDTO
    {
        public string ListUId { get; set; } = string.Empty;
        public string ListName { get; set; } = string.Empty;
        public int Position { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public string BoardUId { get; set; } = string.Empty;
    }
}
