namespace TodoAppAPI.DTOs.Comments
{
    public sealed class CommentUpdateRequest
    {
        public string UserUId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
    }
}
