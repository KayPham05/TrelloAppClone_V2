namespace TodoAppAPI.DTOs
{
    public class VerifyTwoFactorResponse
    {
        public string Message { get; set; } = string.Empty;
        public bool IsTwoFactorEnabled { get; set; }
    }
}
