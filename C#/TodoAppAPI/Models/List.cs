namespace TodoAppAPI.Models
{
    public class List
    {
        public string ListUId { get; set; } = Guid.NewGuid().ToString();
        public string ListName { get; set; } = string.Empty;
        public int Position { get; set; }
        public string Status { get; set; } = "Active";
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public string BoardUId { get; set; } = string.Empty;
        public Board? Board { get; set; }

        public ICollection<Card>? Cards { get; set; }
    }
}
