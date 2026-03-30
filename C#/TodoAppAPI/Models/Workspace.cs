namespace TodoAppAPI.Models
{
    public class Workspace
    {
        public string WorkspaceUId { get; set; } = Guid.NewGuid().ToString();
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string Status { get; set; } = "Active";

        // FK - Owner (ADDED)
        public string OwnerUId { get; set; } = string.Empty;
        public User? Owner { get; set; }

        // Navigation Properties
        public ICollection<Board>? Boards { get; set; } // ← Changed to nullable
        public ICollection<WorkspaceMemberDto>? Members { get; set; } // ← Changed to nullable
    }
}
