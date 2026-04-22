namespace TodoAppAPI.DTOs
{
    public class AuthResponse
    {
        public string Message { get; set; } = string.Empty;
        public string UserUId { get; set; }
        public string? Token { get; set; } // JWT hoặc mock token
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? Bio { get; set; }
        public bool Requires2FA { get; set; }
        public bool RequiresVerification { get; set; }
        public bool IsTwoFactorEnabled { get; set; }
        public bool IsMember { get; set; }
        public int? ExpiresInSeconds { get; set; }
    }
}
