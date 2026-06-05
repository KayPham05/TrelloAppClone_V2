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
            message.Subject = "MÃ£ xÃ¡c thá»±c tÃ i khoáº£n Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>XÃ¡c thá»±c tÃ i khoáº£n Trello Clone</h2>
            <p>MÃ£ xÃ¡c thá»±c cá»§a báº¡n lÃ :</p>
            <h3 style='color:blue;font-size:22px;'>{code}</h3>
            <p>MÃ£ nÃ y sáº½ háº¿t háº¡n sau 5 phÃºt.</p>"
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
            message.Subject = "XÃ¡c thá»±c Ä‘Äƒng nháº­p 2FA â€“ Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>XÃ¡c thá»±c Ä‘Äƒng nháº­p 2FA</h2>
            <p>MÃ£ OTP Ä‘Äƒng nháº­p cá»§a báº¡n lÃ :</p>
            <h3 style='color:green;font-size:22px;'>{code}</h3>
            <p>MÃ£ nÃ y chá»‰ cÃ³ hiá»‡u lá»±c trong <b>2 phÃºt</b>.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendChangePasswordNotificationEmailAsync(string toEmail, string lockToken)
        {
            var senderEmail = _configuration["EmailSettings:SenderEmail"];
            var senderPassword = _configuration["EmailSettings:SenderPassword"];
            var smtpServer = _configuration["EmailSettings:SmtpServer"];
            var smtpPort = int.Parse(_configuration["EmailSettings:Port"] ?? "587");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Kabo", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "ThÃ´ng bÃ¡o thay Ä‘á»•i máº­t kháº©u â€“ Kabo";

            var backendUrl = _configuration["BackendUrl"] ?? "http://localhost:5293";
            var lockUrl = $"{backendUrl}/v1/api/users/lock-account?token={lockToken}";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>ThÃ´ng bÃ¡o báº£o máº­t</h2>
            <p>TÃ i khoáº£n cá»§a báº¡n vá»«a Ä‘Æ°á»£c Ä‘á»•i máº­t kháº©u thÃ nh cÃ´ng vÃ o lÃºc <b>{DateTime.UtcNow:dd/MM/yyyy HH:mm} UTC</b>.</p>
            <p>Náº¿u báº¡n khÃ´ng thá»±c hiá»‡n hÃ nh Ä‘á»™ng nÃ y, vui lÃ²ng báº¥m vÃ o nÃºt dÆ°á»›i Ä‘Ã¢y Ä‘á»ƒ khÃ³a tÃ i khoáº£n kháº©n cáº¥p (link cÃ³ hiá»‡u lá»±c trong 3 ngÃ y):</p>
            <a href='{lockUrl}' style='display:inline-block;padding:10px 20px;background-color:red;color:white;text-decoration:none;border-radius:5px;'>KhÃ³a tÃ i khoáº£n</a>"
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
            message.Subject = "XÃ¡c nháº­n Ä‘á»‹a chá»‰ email má»›i â€“ Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>XÃ¡c nháº­n Ä‘á»‹a chá»‰ email má»›i</h2>
            <p>MÃ£ OTP xÃ¡c nháº­n cá»§a báº¡n lÃ :</p>
            <h3 style='color:green;font-size:22px;'>{code}</h3>
            <p>MÃ£ nÃ y chá»‰ cÃ³ hiá»‡u lá»±c trong <b>15 phÃºt</b>.</p>"
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
                // Fallback náº¿u trong appsettings.json chÆ°a cáº¥u hÃ¬nh BackendUrl
                backendUrl = "http://localhost:5293";
            }
            
            var lockUrl = $"{backendUrl}/v1/api/users/lock-account?token={lockToken}";

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", senderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = "Cáº£nh bÃ¡o báº£o máº­t â€“ YÃªu cáº§u Ä‘á»•i email";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>Cáº£nh bÃ¡o báº£o máº­t</h2>
            <p>TÃ i khoáº£n cá»§a báº¡n Ä‘ang cÃ³ yÃªu cáº§u Ä‘á»•i email sang <b>{newEmail}</b>.</p>
            <p>Náº¿u khÃ´ng pháº£i lÃ  báº¡n, hÃ£y báº¥m vÃ o nÃºt dÆ°á»›i Ä‘Ã¢y Ä‘á»ƒ khÃ³a tÃ i khoáº£n kháº©n cáº¥p (link cÃ³ hiá»‡u lá»±c trong 3 ngÃ y):</p>
            <a href='{lockUrl}' style='display:inline-block;padding:10px 20px;background-color:red;color:white;text-decoration:none;border-radius:5px;'>KhÃ³a tÃ i khoáº£n</a>"
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
            message.Subject = "MÃ£ OTP KhÃ´i phá»¥c máº­t kháº©u â€“ Trello Clone";

            message.Body = new TextPart("html")
            {
                Text = $@"
            <h2>KhÃ´i phá»¥c máº­t kháº©u</h2>
            <p>MÃ£ OTP Ä‘á»ƒ khÃ´i phá»¥c máº­t kháº©u cá»§a báº¡n lÃ :</p>
            <h3 style='color:blue;font-size:22px;'>{code}</h3>
            <p>MÃ£ nÃ y cÃ³ hiá»‡u lá»±c trong <b>5 phÃºt</b>.</p>
            <p>Náº¿u báº¡n khÃ´ng yÃªu cáº§u khÃ´i phá»¥c máº­t kháº©u, vui lÃ²ng bá» qua email nÃ y.</p>"
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(senderEmail, senderPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
    }
}
