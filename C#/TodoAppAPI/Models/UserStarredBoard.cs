namespace TodoAppAPI.Models
{
    public class UserStarredBoard
    {
        public string UserStarredBoardUId { get; set; } = Guid.NewGuid().ToString();
        public string UserUId { get; set; } = string.Empty;
        public string BoardUId { get; set; } = string.Empty;
        public DateTime StarredAt { get; set; } = DateTime.UtcNow;

        public User? User { get; set; }
        public Board? Board { get; set; }
    }
}
