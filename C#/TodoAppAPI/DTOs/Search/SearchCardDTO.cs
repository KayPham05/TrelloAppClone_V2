namespace TodoAppAPI.DTOs.Search
{
    public class SearchCardDTO
    {
        public string CardUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? BoardName { get; set; }
        public string? BoardUId { get; set; }
    }
}
