namespace TodoAppAPI.Models
{
    public class UserInboxCard
    {
        public string UserUId { get; set; } = string.Empty;
        public string CardUId { get; set; } = string.Empty;
        public DateTime AddedAt { get; set; } = DateTime.Now;

        public User? User { get; set; }
        public Card? Card { get; set; }
    }
}
