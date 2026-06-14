namespace TodoAppAPI.Interfaces
{
    public interface IEmailService
    {
        Task SendVerificationEmailAsync(string toEmail, string code);
        Task SendTwoFactorOtpEmailAsync(string toEmail, string code);
        Task SendChangePasswordNotificationEmailAsync(string toEmail, string lockToken);
        Task SendEmailChangeOtpAsync(string toEmail, string code);
        Task SendEmailChangeWarningAsync(string toEmail, string newEmail, string lockToken);
        Task SendPasswordResetOtpEmailAsync(string toEmail, string code);
    }
}
