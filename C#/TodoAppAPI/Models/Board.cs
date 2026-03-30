namespace TodoAppAPI.Models
{
    public class Board
    {
        public string BoardUId { get; set; } = Guid.NewGuid().ToString();
        public string BoardName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public bool IsPersonal { get; set; } = false;
        public string Visibility { get; set; } = "Private";
        public string Status { get; set; } = "Active";

        // FK - Owner
        public string UserUId { get; set; } = string.Empty;
        public User? User { get; set; } // ← Changed from UserOwner

        // FK - Workspace (nullable for personal boards)
        public string? WorkspaceUId { get; set; }
        public Workspace? Workspace { get; set; }

        // Navigation Properties
        public ICollection<List>? Lists { get; set; }
        public ICollection<BoardMember>? Members { get; set; }
    }
}
