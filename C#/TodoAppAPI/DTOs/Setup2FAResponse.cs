namespace TodoAppAPI.DTOs
{
    public class Setup2FAResponse
    {
        public string SecretKey { get; set; } = string.Empty;
        public string QrUri { get; set; } = string.Empty;
    }
}
