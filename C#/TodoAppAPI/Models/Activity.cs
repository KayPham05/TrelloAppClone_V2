namespace TodoAppAPI.Models
{
    public class Activity
    {
        public string ActivityUId { get; set; } = Guid.NewGuid().ToString();
        public string Action { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string? UserUId { get; set; } = null;
        public User? User { get; set; } 
    }
}
