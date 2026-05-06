namespace TodoAppAPI.DTOs
{
    public class Enable2FAResponse
    {
        public string Message { get; set; } = string.Empty;
        public bool IsTwoFactorEnabled { get; set; }
        public List<string> BackupCodes { get; set; } = new();
    }
}
