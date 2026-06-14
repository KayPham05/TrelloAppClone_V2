using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests.Service
{
    public class UserServiceTests
    {
        private readonly TodoDbContext _context;
        private readonly Mock<IEmailService> _mockEmailService;
        private readonly Mock<IJwtService> _mockJwtService;
        private readonly Mock<ILogger<UserService>> _mockLogger;
        private readonly IMemoryCache _memoryCache;
        private readonly Mock<IHubContext<NotificationHub>> _mockHubContext;
        private readonly UserService _userService;

        public UserServiceTests()
        {
            var options = new DbContextOptionsBuilder<TodoDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            _context = new TodoDbContext(options);
            _mockEmailService = new Mock<IEmailService>();
            _mockJwtService = new Mock<IJwtService>();
            _mockLogger = new Mock<ILogger<UserService>>();
            _memoryCache = new MemoryCache(new MemoryCacheOptions());
            
            _mockHubContext = new Mock<IHubContext<NotificationHub>>();
            var mockClients = new Mock<IHubClients>();
            var mockClientProxy = new Mock<IClientProxy>();
            mockClients.Setup(c => c.Group(It.IsAny<string>())).Returns(mockClientProxy.Object);
            _mockHubContext.Setup(x => x.Clients).Returns(mockClients.Object);

            _userService = new UserService(
                _context,
                _mockEmailService.Object,
                _mockJwtService.Object,
                _mockLogger.Object,
                _memoryCache,
                _mockHubContext.Object
            );
        }

        [Fact]
        public async Task ResendVerificationCodeAsync_ThrowsIfEmailIsNullOrEmpty()
        {
            await Assert.ThrowsAsync<ArgumentException>(() => _userService.ResendVerificationCodeAsync(""));
        }

        [Fact]
        public async Task ResendVerificationCodeAsync_ThrowsIfUserNotFound()
        {
            await Assert.ThrowsAsync<Exception>(() => _userService.ResendVerificationCodeAsync("nonexistent@example.com"));
        }

        [Fact]
        public async Task ResendVerificationCodeAsync_ReturnsAlreadyVerifiedMessageIfUserIsVerified()
        {
            var user = new User { UserUId = "1", Email = "verified@example.com", IsEmailVerified = true, StatusAccount = "Active" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.ResendVerificationCodeAsync("verified@example.com");

            Assert.Equal("Tài khoản này đã được xác thực trước đó.", result);
        }

        [Fact]
        public async Task ResendVerificationCodeAsync_GeneratesOtpAndSendsEmail()
        {
            var user = new User { UserUId = "1", Email = "test@example.com", IsEmailVerified = false, StatusAccount = "Active" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.ResendVerificationCodeAsync("test@example.com");

            Assert.Contains("Mã xác thực mới đã được gửi tới email", result);
            _mockEmailService.Verify(e => e.SendVerificationEmailAsync("test@example.com", It.IsAny<string>()), Times.Once);
            
            var updatedUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == "test@example.com");
            Assert.NotNull(updatedUser.VerificationTokenHash);
            
            var otp = await _context.UserOtps.FirstOrDefaultAsync(o => o.UserUId == "1");
            Assert.NotNull(otp);
        }

        [Fact]
        public async Task ChangePasswordAsync_ThrowsIfUserNotFound()
        {
            await Assert.ThrowsAsync<System.Collections.Generic.KeyNotFoundException>(() => _userService.ChangePasswordAsync("nonexistent", "old", "new", null));
        }

        [Fact]
        public async Task ChangePasswordAsync_ThrowsIfOldPasswordIncorrect()
        {
            var hash = BCrypt.Net.BCrypt.HashPassword("correct-old");
            var user = new User { UserUId = "1", PasswordHash = hash };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _userService.ChangePasswordAsync("1", "wrong-old", "new-pass", null));
        }

        [Fact]
        public async Task ChangePasswordAsync_UpdatesPasswordAndSendsEmail()
        {
            var hash = BCrypt.Net.BCrypt.HashPassword("correct-old");
            var user = new User { UserUId = "1", Email = "test@example.com", PasswordHash = hash, Session = new UserSession { RefreshToken = "x" } };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.ChangePasswordAsync("1", "correct-old", "new-pass", null);

            Assert.NotNull(result);
            _mockEmailService.Verify(e => e.SendChangePasswordNotificationEmailAsync("test@example.com", It.IsAny<string>()), Times.Once);
            
            var updatedUser = await _context.Users.FindAsync("1");
            Assert.True(BCrypt.Net.BCrypt.Verify("new-pass", updatedUser.PasswordHash));
        }

        [Fact]
        public async Task LockAccountAsync_LocksUser()
        {
            var user = new User { UserUId = "1", StatusAccount = "Active" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            _memoryCache.Set("LockAccount_valid-token", "1|old@example.com");

            var result = await _userService.LockAccountAsync("valid-token");

            Assert.True(result);
            var updatedUser = await _context.Users.FindAsync("1");
            Assert.Equal("Locked", updatedUser.StatusAccount);
        }
        
        [Fact]
        public async Task SendChangeEmailOtpAsync_ThrowsIfUserNotFound()
        {
            await Assert.ThrowsAsync<System.Collections.Generic.KeyNotFoundException>(() => _userService.SendChangeEmailOtpAsync("1", "new@example.com", "pass", null));
        }

        [Fact]
        public async Task SendChangeEmailOtpAsync_SendsOtpAndWarning()
        {
            var user = new User { UserUId = "1", Email = "old@example.com", StatusAccount = "Active", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass") };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.SendChangeEmailOtpAsync("1", "new@example.com", "pass", null);

            Assert.True(result);
            _mockEmailService.Verify(e => e.SendEmailChangeOtpAsync("new@example.com", It.IsAny<string>()), Times.Once);
            _mockEmailService.Verify(e => e.SendEmailChangeWarningAsync("old@example.com", "new@example.com", It.IsAny<string>()), Times.Once);
        }
        
        [Fact]
        public async Task CheckChangeEmailAsync_ReturnsFalseIfOtpInvalid()
        {
            var user = new User { UserUId = "1", Email = "old@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass") };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _userService.CheckChangeEmailAsync("1", "new@example.com", "wrongpass"));
        }

        [Fact]
        public async Task ConfirmChangeEmailAsync_UpdatesEmail()
        {
            var user = new User { UserUId = "1", Email = "old@example.com", StatusAccount = "Active" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            
            _memoryCache.Set($"ChangeEmailOtp_1_new@example.com", "123456");

            var result = await _userService.ConfirmChangeEmailAsync("1", "new@example.com", "123456");

            Assert.True(result);
            var updatedUser = await _context.Users.FindAsync("1");
            Assert.Equal("new@example.com", updatedUser.Email);
        }
    }
}
