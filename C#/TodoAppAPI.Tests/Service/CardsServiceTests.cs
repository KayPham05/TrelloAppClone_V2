using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests.Service
{
    public class CardsServiceTests
    {
        [Fact]
        public async Task UpdateAttachmentNameAsync_should_update_FileName()
        {
            // Arrange
            await using var context = CreateContext();
            var authMock = new Mock<IAuthorizationService>();
            authMock.Setup(a => a.CanEditCardAsync(It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync(true);
            
            var service = new CardsService(
                context,
                authMock.Object,
                new Mock<INotificationService>().Object,
                new Mock<ICardDueDateReminderService>().Object);

            var card = new Card { CardUId = "card-1", Title = "Card 1", ListUId = "list-1", UserUId = "user-1", Status = "Active" };
            context.Todos.Add(card);

            var fileUrl = new FileUrl
            {
                FileUId = "file-1",
                CardUId = "card-1",
                Url = "http://example.com/file.png",
                FileName = "old-name.png",
                CreatedAt = DateTime.UtcNow
            };
            context.FileUrls.Add(fileUrl);
            await context.SaveChangesAsync();

            // Act
            var result = await service.UpdateAttachmentNameAsync("file-1", "user-1", "new-name.png");

            // Assert
            Assert.True(result);
            var updatedFile = await context.FileUrls.FindAsync("file-1");
            Assert.NotNull(updatedFile);
            Assert.Equal("new-name.png", updatedFile.FileName);
        }

        [Fact]
        public async Task UpdateAttachmentNameAsync_should_return_false_when_file_does_not_exist()
        {
            // Arrange
            await using var context = CreateContext();
            var authMock = new Mock<IAuthorizationService>();
            
            var service = new CardsService(
                context,
                authMock.Object,
                new Mock<INotificationService>().Object,
                new Mock<ICardDueDateReminderService>().Object);

            // Act
            var result = await service.UpdateAttachmentNameAsync("non-existent-file", "user-1", "new-name.png");

            // Assert
            Assert.False(result);
        }

        [Fact]
        public async Task UpdateAttachmentNameAsync_should_return_false_when_user_cannot_edit_card()
        {
            // Arrange
            await using var context = CreateContext();
            var authMock = new Mock<IAuthorizationService>();
            authMock.Setup(a => a.CanEditCardAsync("card-unauthorized", "user-1")).ReturnsAsync(false);

            var service = new CardsService(
                context,
                authMock.Object,
                new Mock<INotificationService>().Object,
                new Mock<ICardDueDateReminderService>().Object);

            var card = new Card { CardUId = "card-unauthorized", Title = "Card Unauthorized", ListUId = "list-1", UserUId = "user-1", Status = "Active" };
            context.Todos.Add(card);

            var fileUrl = new FileUrl
            {
                FileUId = "file-unauthorized",
                CardUId = "card-unauthorized",
                Url = "http://example.com/file.png",
                FileName = "old-name.png",
                CreatedAt = DateTime.UtcNow
            };
            context.FileUrls.Add(fileUrl);
            await context.SaveChangesAsync();

            // Act
            var result = await service.UpdateAttachmentNameAsync("file-unauthorized", "user-1", "new-name.png");

            // Assert
            Assert.False(result);
            var unchangedFile = await context.FileUrls.FindAsync("file-unauthorized");
            Assert.NotNull(unchangedFile);
            Assert.Equal("old-name.png", unchangedFile.FileName);
        }

        [Fact]
        public async Task UpdateAttachmentNameAsync_should_return_false_when_authorization_throws()
        {
            // Arrange
            await using var context = CreateContext();
            var authMock = new Mock<IAuthorizationService>();
            authMock.Setup(a => a.CanEditCardAsync("card-auth-error", "user-1"))
                .ThrowsAsync(new InvalidOperationException("auth failed"));

            var service = new CardsService(
                context,
                authMock.Object,
                new Mock<INotificationService>().Object,
                new Mock<ICardDueDateReminderService>().Object);

            var card = new Card { CardUId = "card-auth-error", Title = "Card Auth Error", ListUId = "list-1", UserUId = "user-1", Status = "Active" };
            context.Todos.Add(card);

            var fileUrl = new FileUrl
            {
                FileUId = "file-auth-error",
                CardUId = "card-auth-error",
                Url = "http://example.com/file.png",
                FileName = "old-name.png",
                CreatedAt = DateTime.UtcNow
            };
            context.FileUrls.Add(fileUrl);
            await context.SaveChangesAsync();

            // Act
            var result = await service.UpdateAttachmentNameAsync("file-auth-error", "user-1", "new-name.png");

            // Assert
            Assert.False(result);
            var unchangedFile = await context.FileUrls.FindAsync("file-auth-error");
            Assert.NotNull(unchangedFile);
            Assert.Equal("old-name.png", unchangedFile.FileName);
        }

        [Fact]
        public async Task DeleteAttachmentAsync_should_remove_fileUrl_from_database()
        {
            // Arrange
            await using var context = CreateContext();
            var authMock = new Mock<IAuthorizationService>();
            authMock.Setup(a => a.CanEditCardAsync(It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync(true);
            
            var service = new CardsService(
                context,
                authMock.Object,
                new Mock<INotificationService>().Object,
                new Mock<ICardDueDateReminderService>().Object);

            var card = new Card { CardUId = "card-2", Title = "Card 2", ListUId = "list-2", UserUId = "user-1", Status = "Active" };
            context.Todos.Add(card);

            var fileUrl = new FileUrl
            {
                FileUId = "file-2",
                CardUId = "card-2",
                Url = "http://example.com/file2.png",
                FileName = "delete-me.png",
                CreatedAt = DateTime.UtcNow
            };
            context.FileUrls.Add(fileUrl);
            await context.SaveChangesAsync();

            // Act
            var result = await service.DeleteAttachmentAsync("file-2", "user-2");

            // Assert
            Assert.True(result);
            var deletedFile = await context.FileUrls.FindAsync("file-2");
            Assert.Null(deletedFile);
        }

        private static TodoDbContext CreateContext()
        {
            var options = new DbContextOptionsBuilder<TodoDbContext>()
                .UseInMemoryDatabase(Guid.NewGuid().ToString())
                .Options;

            return new TodoDbContext(options);
        }
    }
}
