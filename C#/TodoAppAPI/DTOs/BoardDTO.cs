namespace TodoAppAPI.DTOs
{
    public class BoardDTO
    {
        public string BoardUId { get; set; } = string.Empty;
        public string BoardName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public bool IsPersonal { get; set; }
        public string Visibility { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string UserUId { get; set; } = string.Empty;
        public string? WorkspaceUId { get; set; }
        public string? BackgroundUrl { get; set; }
        public bool IsStarred { get; set; }
    }
}
