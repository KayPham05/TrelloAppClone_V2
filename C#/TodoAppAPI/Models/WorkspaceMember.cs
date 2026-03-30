namespace TodoAppAPI.Models
{
    public class WorkspaceMemberDto
    {
        public string WorkspaceMemberUId { get; set; } = Guid.NewGuid().ToString();
        public string WorkspaceUId { get; set; } = string.Empty;
        public string UserUId { get; set; } = string.Empty;
        public string Role { get; set; } = "Member";
        public DateTime JoinedAt { get; set; } = DateTime.Now;

        public Workspace? Workspace { get; set; }
        public User? User { get; set; }
    }
}
