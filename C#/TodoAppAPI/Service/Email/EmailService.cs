using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace TodoAppAPI.Service
{
    public class EmailService
    {
        public async Task SendVerificationEmailAsync(string toEmail, string code)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", "no-reply@yourdomain.com"));
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
            await client.ConnectAsync("smtp.gmail.com", 587, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync("6451071030@st.utc2.edu.vn", "cbbr ghvb zocr mnbk");
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendTwoFactorOtpEmailAsync(string toEmail, string code)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trello Clone", "no-reply@yourdomain.com"));
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
            await client.ConnectAsync("smtp.gmail.com", 587, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync("6451071030@st.utc2.edu.vn", "cbbr ghvb zocr mnbk");
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }

        public async Task SendChangePasswordNotificationEmailAsync(string toEmail)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Trellon", "no-reply@yourdomain.com"));
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
            await client.ConnectAsync("smtp.gmail.com", 587, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync("6451071030@st.utc2.edu.vn", "cbbr ghvb zocr mnbk");
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
    }
}
