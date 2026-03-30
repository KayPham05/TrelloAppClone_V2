namespace TodoAppAPI.Models
{
    public class BoardMember
    {
        public string BoardMemberUId { get; set; } = Guid.NewGuid().ToString();
        public string BoardUId { get; set; } = string.Empty;
        public string UserUId { get; set; } = string.Empty;
        public string BoardRole { get; set; } = "Viewer"; // ← Changed from "viewer"
        public DateTime InvitedAt { get; set; } = DateTime.Now;

        public Board? Board { get; set; }
        public User? User { get; set; }
    }
}
