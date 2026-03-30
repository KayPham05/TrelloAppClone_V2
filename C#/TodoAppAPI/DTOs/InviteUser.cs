namespace TodoAppAPI.DTOs
{
    public class InviteUser
    {
        public string UserId { get; set; } = string.Empty;
        public string Role { get; set; }
        public string RequesterUId { get; set; }
    }
}
