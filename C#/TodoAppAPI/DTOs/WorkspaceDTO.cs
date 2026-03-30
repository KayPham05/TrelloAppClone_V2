namespace TodoAppAPI.DTOs
{
    public class WorkspaceDTO
    {
        public string WorkspaceUId { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public string OwnerName { get; set; }
        public List<MemberDTO> Members { get; set; } = new();
    }
}
