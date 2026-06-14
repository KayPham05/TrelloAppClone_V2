using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Moq;
using MimeKit;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests.Service
{
    public class EmailServiceTests
    {
        private class TestEmailService : EmailService
        {
            public MimeMessage? LastMessage { get; private set; }
            
            public TestEmailService(IConfiguration config) : base(config)
            {
            }

            protected override Task SendEmailMessageAsync(MimeMessage message, string smtpServer, int smtpPort, string senderEmail, string senderPassword)
            {
                LastMessage = message;
                return Task.CompletedTask;
            }
        }

        private readonly TestEmailService _emailService;

        public EmailServiceTests()
        {
            var config = new Mock<IConfiguration>();
            config.Setup(c => c["EmailSettings:SenderEmail"]).Returns("test@example.com");
            config.Setup(c => c["EmailSettings:SenderPassword"]).Returns("password");
            config.Setup(c => c["EmailSettings:SmtpServer"]).Returns("smtp.example.com");
            config.Setup(c => c["EmailSettings:Port"]).Returns("587");
            config.Setup(c => c["BackendUrl"]).Returns("http://localhost:5293");

            _emailService = new TestEmailService(config.Object);
        }

        [Fact]
        public async Task SendVerificationEmailAsync_SendsEmail()
        {
            await _emailService.SendVerificationEmailAsync("user@example.com", "123456");

            Assert.NotNull(_emailService.LastMessage);
            Assert.Contains("user@example.com", _emailService.LastMessage.To.ToString());
            Assert.Contains("123456", _emailService.LastMessage.HtmlBody);
        }

        [Fact]
        public async Task SendTwoFactorOtpEmailAsync_SendsEmail()
        {
            await _emailService.SendTwoFactorOtpEmailAsync("user@example.com", "123456");

            Assert.NotNull(_emailService.LastMessage);
            Assert.Contains("user@example.com", _emailService.LastMessage.To.ToString());
            Assert.Contains("123456", _emailService.LastMessage.HtmlBody);
        }

        [Fact]
        public async Task SendChangePasswordNotificationEmailAsync_SendsEmail()
        {
            await _emailService.SendChangePasswordNotificationEmailAsync("user@example.com", "token123");

            Assert.NotNull(_emailService.LastMessage);
            Assert.Contains("user@example.com", _emailService.LastMessage.To.ToString());
            Assert.Contains("token123", _emailService.LastMessage.HtmlBody);
        }

        [Fact]
        public async Task SendEmailChangeOtpAsync_SendsEmail()
        {
            await _emailService.SendEmailChangeOtpAsync("user@example.com", "123456");

            Assert.NotNull(_emailService.LastMessage);
            Assert.Contains("user@example.com", _emailService.LastMessage.To.ToString());
            Assert.Contains("123456", _emailService.LastMessage.HtmlBody);
        }

        [Fact]
        public async Task SendEmailChangeWarningAsync_SendsEmail()
        {
            await _emailService.SendEmailChangeWarningAsync("user@example.com", "new@example.com", "token123");

            Assert.NotNull(_emailService.LastMessage);
            Assert.Contains("user@example.com", _emailService.LastMessage.To.ToString());
            Assert.Contains("new@example.com", _emailService.LastMessage.HtmlBody);
            Assert.Contains("token123", _emailService.LastMessage.HtmlBody);
        }

        [Fact]
        public async Task SendPasswordResetOtpEmailAsync_SendsEmail()
        {
            await _emailService.SendPasswordResetOtpEmailAsync("user@example.com", "123456");

            Assert.NotNull(_emailService.LastMessage);
            Assert.Contains("user@example.com", _emailService.LastMessage.To.ToString());
            Assert.Contains("123456", _emailService.LastMessage.HtmlBody);
        }
    }
}
