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
    }
}
