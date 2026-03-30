namespace TodoAppAPI.DTOs
{
    public class AddTodoItemRequest
    {
        public string CardUId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
    }
}
