namespace TodoAppAPI.Models
{
    public class Comment
    {
        public string CommentUId { get; set; } = Guid.NewGuid().ToString();
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public string CardUId { get; set; } = string.Empty;
        public Card? Card { get; set; }

        public string? UserUId { get; set; }
        public User? User { get; set; }
    }
}
