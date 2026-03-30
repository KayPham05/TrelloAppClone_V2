namespace TodoAppAPI.Models
{
    public class UserRecentBoard
    {
        public string UserRecentBoardUId { get; set; } = Guid.NewGuid().ToString();
        public string UserUId { get; set; } = string.Empty;
        public string BoardUId {  get; set; } = string.Empty;
        public DateTime LastVisitedAt { get; set; } = DateTime.UtcNow;

        public User? User { get; set; }
        public Board? Board { get; set; }
    }
}
