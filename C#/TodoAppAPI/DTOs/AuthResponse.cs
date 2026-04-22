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
        public bool requires2FA { get; set; }
        public bool requiresVerification { get; set; }
        public bool IsTwoFactorEnabled { get; set; }
        public bool IsMember { get; set; }
        public string? RefreshToken { get; set; }
        public int? ExpiresInSeconds { get; set; }
    }
}
