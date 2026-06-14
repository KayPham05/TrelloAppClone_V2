using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Moq;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Data;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests.Service
{
    public class UserServiceBasicTests
    {
        private readonly TodoDbContext _context;
        private readonly Mock<IEmailService> _mockEmailService;
        private readonly Mock<IJwtService> _mockJwtService;
        private readonly Mock<ILogger<UserService>> _mockLogger;
        private readonly IMemoryCache _memoryCache;
        private readonly Mock<IHubContext<NotificationHub>> _mockHubContext;
        private readonly UserService _userService;

        public UserServiceBasicTests()
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
        public async Task GetAllAsync_ReturnsAllUsers()
        {
            _context.Users.Add(new User { UserUId = "1", Email = "a@a.com" });
            _context.Users.Add(new User { UserUId = "2", Email = "b@b.com" });
            await _context.SaveChangesAsync();

            var users = await _userService.GetAllAsync();
            Assert.Equal(2, users.Count());
        }

        [Fact]
        public async Task GetByIdAsync_ReturnsUser()
        {
            _context.Users.Add(new User { UserUId = "1", Email = "a@a.com" });
            await _context.SaveChangesAsync();

            var user = await _userService.GetByIdAsync("1");
            Assert.NotNull(user);
            Assert.Equal("1", user.UserUId);
        }

        [Fact]
        public async Task AddAsync_AddsUser()
        {
            var user = new User { UserUId = "1", Email = "a@a.com" };
            await _userService.AddAsync(user);

            var added = await _context.Users.FindAsync("1");
            Assert.NotNull(added);
        }

        [Fact]
        public async Task UpdateAsync_UpdatesUser()
        {
            var user = new User { UserUId = "1", Email = "a@a.com" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            user.Email = "updated@a.com";
            await _userService.UpdateAsync(user);

            var updated = await _context.Users.FindAsync("1");
            Assert.Equal("updated@a.com", updated.Email);
        }

        [Fact]
        public async Task DeleteAsync_DeletesUser()
        {
            var user = new User { UserUId = "1", Email = "a@a.com" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            await _userService.DeleteAsync("1");

            var deleted = await _context.Users.FindAsync("1");
            Assert.Null(deleted);
        }

        [Fact]
        public async Task GetUserByEmail_ReturnsUser()
        {
            var user = new User { UserUId = "1", Email = "a@a.com" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.GetUserByEmail("a@a.com");
            Assert.NotNull(result);
            Assert.Equal("1", result.UserUId);
        }

        [Fact]
        public async Task AddBioByUserUId_UpdatesBio()
        {
            var user = new User { UserUId = "1", Email = "a@a.com" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.AddBioByUserUId("1", "My Bio");
            Assert.True(result);

            var updated = await _context.Users.FindAsync("1");
            Assert.Equal("My Bio", updated.Bio);
        }

        [Fact]
        public async Task AddUserUSerName_UpdatesUserName()
        {
            var user = new User { UserUId = "1", Email = "a@a.com" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.AddUserUSerName("1", "new_username");
            Assert.True(result);

            var updated = await _context.Users.FindAsync("1");
            Assert.Equal("new_username", updated.UserName);
        }

        [Fact]
        public async Task UpdateStatusAccount_UpdatesStatus()
        {
            var user = new User { UserUId = "1", Email = "a@a.com", StatusAccount = "Active" };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            await _userService.UpdateStatusAccount("1", "Inactive");

            var updated = await _context.Users.FindAsync("1");
            Assert.Equal("Logout", updated.StatusAccount);
        }

        [Fact]
        public async Task ToggleTwoFactorAsync_Updates2FA()
        {
            var user = new User { UserUId = "1", Email = "a@a.com", IsTwoFactorEnabled = false };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var result = await _userService.ToggleTwoFactorAsync("1", true);
            Assert.True(result);

            var updated = await _context.Users.FindAsync("1");
            Assert.True(updated.IsTwoFactorEnabled);
        }
    }
}
