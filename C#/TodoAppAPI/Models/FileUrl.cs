namespace TodoAppAPI.Models
{
    public class FileUrl
    {
        public string FileUId { get; set; } = Guid.NewGuid().ToString();
        
        public string Url { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public string CardUId { get; set; } = string.Empty;

        public virtual Card? Card { get; set; }
    }
}
