namespace TodoAppAPI.DTOs
{
    public class InboxReorderItem
    {
        public string CardUId { get; set; } = string.Empty;
        public int Position { get; set; }
    }

    public class InboxReorderRequest
    {
        public List<InboxReorderItem> Items { get; set; } = new();
    }
}
