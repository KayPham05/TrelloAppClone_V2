using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests;

public class CommentServiceTests
{
    [Fact]
    public async Task AddCommentAsync_creates_comment_and_notifications()
    {
        await using var context = CreateContext();
        var mockNotificationService = new Mock<INotificationService>();
        var service = new CommentService(context, mockNotificationService.Object);

        context.Users.Add(new User { UserUId = "u1", UserName = "User1" });
        context.Users.Add(new User { UserUId = "u2", UserName = "User2" });
        context.Todos.Add(new Card 
        { 
            CardUId = "c1", 
            ListUId = "l1", 
            Title = "Test Card",
            Status = "Active",
            CardMembers = new List<CardMember> { new CardMember { UserUId = "u2" } }
        });
        await context.SaveChangesAsync();

        var comment = new Comment
        {
            CardUId = "c1",
            UserUId = "u1",
            Content = "Hello @User2"
        };

        var result = await service.AddCommentAsync(comment);

        Assert.NotNull(result);
        Assert.Equal("Hello @User2", result.Content);
        
        // Assert notifications were created
        mockNotificationService.Verify(n => n.CreateManyInternalAsync(It.IsAny<IEnumerable<TodoAppAPI.DTOs.NotificationDTO>>()), Times.Exactly(2));
    }

    [Fact]
    public async Task GetCommentsByCardAsync_returns_comments_with_includes()
    {
        await using var context = CreateContext();
        var service = new CommentService(context, new Mock<INotificationService>().Object);

        context.Comments.Add(new Comment { CommentUId = "c1", CardUId = "card1", CreatedAt = DateTime.UtcNow });
        context.Comments.Add(new Comment { CommentUId = "c2", CardUId = "card1", CreatedAt = DateTime.UtcNow.AddMinutes(-5) });
        await context.SaveChangesAsync();

        var comments = await service.GetCommentsByCardAsync("card1");

        Assert.Equal(2, comments.Count);
        Assert.Equal("c1", comments[0].CommentUId); // Ordered descending by CreatedAt
    }

    [Fact]
    public async Task UpdateCommentAsync_updates_existing_comment()
    {
        await using var context = CreateContext();
        var service = new CommentService(context, new Mock<INotificationService>().Object);

        context.Comments.Add(new Comment { CommentUId = "c1", Content = "Old" });
        await context.SaveChangesAsync();

        var result = await service.UpdateCommentAsync(new Comment { CommentUId = "c1", Content = "New" });

        Assert.True(result);
        var updated = await context.Comments.FindAsync("c1");
        Assert.Equal("New", updated!.Content);
        Assert.NotNull(updated.UpdatedAt);
    }

    [Fact]
    public async Task DeleteCommentAsync_removes_comment()
    {
        await using var context = CreateContext();
        var service = new CommentService(context, new Mock<INotificationService>().Object);

        context.Comments.Add(new Comment { CommentUId = "c1" });
        await context.SaveChangesAsync();

        var result = await service.DeleteCommentAsync("c1");

        Assert.True(result);
        Assert.Null(await context.Comments.FindAsync("c1"));
    }

    [Fact]
    public async Task AddAttachmentAsync_adds_attachment_if_user_owns_comment()
    {
        await using var context = CreateContext();
        var service = new CommentService(context, new Mock<INotificationService>().Object);

        context.Comments.Add(new Comment { CommentUId = "c1", UserUId = "u1" });
        await context.SaveChangesAsync();

        var attachment = await service.AddAttachmentAsync("c1", "http://example.com/file", "file.txt", "u1");

        Assert.NotNull(attachment);
        Assert.Equal("file.txt", attachment.FileName);
        
        // Fails for non-owner
        var attachmentFail = await service.AddAttachmentAsync("c1", "http://example.com/file", "file.txt", "u2");
        Assert.Null(attachmentFail);
    }

    [Fact]
    public async Task RemoveAttachmentAsync_removes_attachment_if_user_owns_comment()
    {
        await using var context = CreateContext();
        var service = new CommentService(context, new Mock<INotificationService>().Object);

        var comment = new Comment { CommentUId = "c1", UserUId = "u1" };
        var attachment = new CommentAttachment { AttachmentUId = "a1", CommentUId = "c1", Comment = comment };
        context.Comments.Add(comment);
        context.CommentAttachments.Add(attachment);
        await context.SaveChangesAsync();

        // Fails for non-owner
        var resultFail = await service.RemoveAttachmentAsync("a1", "u2");
        Assert.False(resultFail);

        // Succeeds for owner
        var result = await service.RemoveAttachmentAsync("a1", "u1");
        Assert.True(result);
        Assert.Null(await context.CommentAttachments.FindAsync("a1"));
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new TodoDbContext(options);
    }
}
