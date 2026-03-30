namespace TodoAppAPI.DTOs
{
    public class UpdateListRequest
    {
        public string? ListUId { get; set; }
        public string UserUId { get; set; } = string.Empty;
    }
}
