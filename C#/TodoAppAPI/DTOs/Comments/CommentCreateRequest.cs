namespace TodoAppAPI.DTOs.Comments
{
    public sealed class CommentCreateRequest
    {
        public string CardUId { get; set; } = string.Empty;
        public string UserUId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
    }
}
