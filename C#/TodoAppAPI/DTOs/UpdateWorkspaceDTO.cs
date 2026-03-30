namespace TodoAppAPI.DTOs
{
    public class UpdateWorkspaceDTO
    {
        public string WorkspaceId { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public string RequesterUId { get; set; }
    }
}
