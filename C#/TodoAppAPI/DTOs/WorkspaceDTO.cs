namespace TodoAppAPI.DTOs
{
    public class WorkspaceDTO
    {
        public string WorkspaceUId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }

        public string OwnerName { get; set; } = string.Empty;
        public string OwnerUId { get; set; } = string.Empty;
        public string Type { get; set; } = "personal"; // personal | team
        public List<MemberDTO> Members { get; set; } = new();
        public List<BoardDTO> Boards { get; set; } = new();
    }
}
