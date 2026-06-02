using Microsoft.Extensions.Configuration;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace TodoAppAPI.Service
{
    public class EmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendVerificationEmailAsync(string toEmail, string code)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Mã xác thực tài khoản Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Xác thực tài khoản Trello Clone</h2>
            <p>Mã xác thực của bạn là:</p>
            <h3 style='color:blue;font-size:22px;'>{code}</h3>
            <p>Mã này sẽ hết hạn sau 5 phút.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendTwoFactorOtpEmailAsync(string toEmail, string code)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Xác thực đăng nhập 2FA – Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Xác thực đăng nhập 2FA</h2>
            <p>Mã OTP đăng nhập của bạn là:</p>
            <h3 style='color:green;font-size:22px;'>{code}</h3>
            <p>Mã này chỉ có hiệu lực trong <b>2 phút</b>.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendChangePasswordNotificationEmailAsync(string toEmail)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trellon", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Thông báo thay đổi mật khẩu – Trellon";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Thông báo bảo mật</h2>
            <p>Tài khoản của bạn vừa được đổi mật khẩu thành công vào lúc <b>{DateTime.UtcNow:dd/MM/yyyy HH:mm} UTC</b>.</p>
            <p>Nếu bạn không thực hiện hành động này, vui lòng liên hệ bộ phận hỗ trợ ngay lập tức.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
        public async Task SendEmailChangeOtpAsync(string toEmail, string code)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Xác nhận địa chỉ email mới – Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Xác nhận địa chỉ email mới</h2>
            <p>Mã OTP xác nhận của bạn là:</p>
            <h3 style='color:green;font-size:22px;'>{code}</h3>
            <p>Mã này chỉ có hiệu lực trong <b>15 phút</b>.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendEmailChangeWarningAsync(string toEmail, string newEmail, string lockToken)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");
            
            var backendUrl = _configuration["BackendUrl"];
            if (string.IsNullOrEmpty(backendUrl) || backendUrl.Trim().ToLower() == "null") 
            {
                // Fallback nếu trong appsettings.json chưa cấu hình BackendUrl
                backendUrl = "http://localhost:5293";
            }
            
            var lockUrl = $"{backendUrl}/v1/api/users/lock-account?token={lockToken}";

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Cảnh báo bảo mật – Yêu cầu đổi email";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Cảnh báo bảo mật</h2>
            <p>Tài khoản của bạn đang có yêu cầu đổi email sang <b>{newEmail}</b>.</p>
            <p>Nếu không phải là bạn, hãy bấm vào nút dưới đây để khóa tài khoản khẩn cấp (link có hiệu lực trong 3 ngày):</p>
            <a href='{lockUrl}' style='display:inline-block;padding:10px 20px;background-color:red;color:white;text-decoration:none;border-radius:5px;'>Khóa tài khoản</a>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendPasswordResetOtpEmailAsync(string toEmail, string code)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Mã OTP Khôi phục mật khẩu – Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Khôi phục mật khẩu</h2>
            <p>Mã OTP để khôi phục mật khẩu của bạn là:</p>
            <h3 style='color:blue;font-size:22px;'>{code}</h3>
            <p>Mã này có hiệu lực trong <b>5 phút</b>.</p>
            <p>Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng bỏ qua email này.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
    }
}
