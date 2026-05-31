namespace TodoAppAPI.DTOs
{
    public class GoogleUserInfo
    {
        public string? Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Picture { get; set; }
    }
}
