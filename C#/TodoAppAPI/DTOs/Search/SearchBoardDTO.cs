namespace TodoAppAPI.DTOs.Search
{
    public class SearchBoardDTO
    {
        public string BoardUId { get; set; } = string.Empty;
        public string BoardName { get; set; } = string.Empty;
        public string? BackgroundUrl { get; set; }
    }
}
