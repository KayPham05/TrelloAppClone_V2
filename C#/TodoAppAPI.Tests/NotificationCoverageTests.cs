using System.Security.Claims;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Controllers;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Hubs;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;
using ModelList = TodoAppAPI.Models.List;

namespace TodoAppAPI.Tests;

public class NotificationCoverageTests
{
    [Fact]
    public async Task GetNotificationsAsync_sentToMe_filters_only_unread_direct_types()
    {
        await using var context = CreateContext();
        SeedUsers(context, "user-1", "actor");
        context.Notifications.AddRange(
            Notification("n1", "user-1", NotificationType.Assign, false),
            Notification("n2", "user-1", NotificationType.Mention, false),
            Notification("n3", "user-1", NotificationType.Comment, false),
            Notification("n4", "other-user", NotificationType.Assign, false),
            Notification("n5", "user-1", NotificationType.Assign, true));
        await context.SaveChangesAsync();
        var service = new NotificationService(context, CreateHubContext());

        var page = await service.GetNotificationsAsync("user-1", NotificationTab.SentToMe, 1, 20);

        Assert.Equal(new[] { "n2", "n1" }, page.Items.Select(i => i.NotiId).ToArray());
        Assert.Equal(3, page.UnreadCount);
    }

    [Fact]
    public async Task GetNotificationsAsync_unread_returns_only_unread_for_user()
    {
        await using var context = CreateContext();
        SeedUsers(context, "user-1");
        context.Notifications.AddRange(
            Notification("n1", "user-1", NotificationType.Assign, false),
            Notification("n2", "user-1", NotificationType.Assign, true),
            Notification("n3", "other-user", NotificationType.Assign, false));
        await context.SaveChangesAsync();
        var service = new NotificationService(context, CreateHubContext());

        var page = await service.GetNotificationsAsync("user-1", NotificationTab.Unread, 1, 20);

        Assert.Single(page.Items);
        Assert.Equal("n1", page.Items[0].NotiId);
        Assert.Equal(1, page.UnreadCount);
    }

    [Fact]
    public async Task GetNotificationsAsync_read_returns_only_read_for_user()
    {
        await using var context = CreateContext();
        SeedUsers(context, "user-1");
        context.Notifications.AddRange(
            Notification("n1", "user-1", NotificationType.Assign, false),
            Notification("n2", "user-1", NotificationType.Assign, true),
            Notification("n3", "other-user", NotificationType.Assign, true));
        await context.SaveChangesAsync();
        var service = new NotificationService(context, CreateHubContext());

        var page = await service.GetNotificationsAsync("user-1", NotificationTab.Read, 1, 20);

        Assert.Single(page.Items);
        Assert.Equal("n2", page.Items[0].NotiId);
        Assert.Equal(1, page.UnreadCount);
    }

    [Fact]
    public async Task MarkAsReadAsync_rejects_notification_owned_by_other_user()
    {
        await using var context = CreateContext();
        SeedUsers(context, "user-1", "user-2");
        context.Notifications.Add(Notification("n1", "user-2", NotificationType.Assign, false));
        await context.SaveChangesAsync();
        var service = new NotificationService(context, CreateHubContext());

        var result = await service.MarkAsReadAsync("user-1", "n1");

        Assert.False(result);
        Assert.False((await context.Notifications.FindAsync("n1"))!.Read);
    }

    [Fact]
    public async Task DeleteAsync_rejects_notification_owned_by_other_user()
    {
        await using var context = CreateContext();
        SeedUsers(context, "user-1", "user-2");
        context.Notifications.Add(Notification("n1", "user-2", NotificationType.Assign, false));
        await context.SaveChangesAsync();
        var service = new NotificationService(context, CreateHubContext());

        var result = await service.DeleteAsync("user-1", "n1");

        Assert.False(result);
        Assert.True(await context.Notifications.AnyAsync(n => n.NotiId == "n1"));
    }

    [Fact]
    public void CreateNotification_returns_403_in_development()
    {
        var env = new Mock<IWebHostEnvironment>();
        env.SetupGet(e => e.EnvironmentName).Returns("Development");
        var controller = new NotificationController(
            Mock.Of<TodoAppAPI.Interfaces.INotificationService>(),
            env.Object);

        var result = controller.CreateNotification();

        var objectResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status403Forbidden, objectResult.StatusCode);
    }

    [Fact]
    public async Task CommentService_AddCommentAsync_creates_mentions_for_card_members_only()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member", "outsider");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.CardMembers.Add(new CardMember
        {
            CardMemberUId = "member-1",
            CardUId = "card-1",
            UserUId = "member",
            Role = "Assignee"
        });
        await context.SaveChangesAsync();
        var service = new CommentService(context, CreateRecordingNotificationService(context));

        await service.AddCommentAsync(new Comment
        {
            CardUId = "card-1",
            UserUId = "actor",
            Content = "@member @outsider review this"
        });

        var notifications = await context.Notifications.ToListAsync();
        Assert.Single(notifications);
        Assert.Equal("member", notifications[0].RecipientId);
        Assert.Equal(NotificationType.Mention, notifications[0].Type);
    }

    [Fact]
    public async Task CommentService_AddCommentAsync_dedupes_duplicate_mentions()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.CardMembers.Add(new CardMember
        {
            CardMemberUId = "member-1",
            CardUId = "card-1",
            UserUId = "member",
            Role = "Assignee"
        });
        await context.SaveChangesAsync();
        var service = new CommentService(context, CreateRecordingNotificationService(context));

        await service.AddCommentAsync(new Comment
        {
            CardUId = "card-1",
            UserUId = "actor",
            Content = "@member @member @MEMBER"
        });

        Assert.Single(await context.Notifications.ToListAsync());
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new TodoDbContext(options);
    }

    private static void SeedUsers(TodoDbContext context, params string[] ids)
    {
        foreach (var id in ids)
        {
            context.Users.Add(new User
            {
                UserUId = id,
                UserName = id,
                Email = $"{id}@example.com",
                PasswordHash = "hash",
                StatusAccount = "Active"
            });
        }
        context.SaveChanges();
    }

    private static void SeedBoardListAndCard(
        TodoDbContext context,
        string boardId,
        string listId,
        string cardId,
        string ownerId)
    {
        context.Boards.Add(new Board { BoardUId = boardId, BoardName = "Roadmap", UserUId = ownerId });
        context.Lists.Add(new ModelList { ListUId = listId, BoardUId = boardId, ListName = "Doing" });
        context.Todos.Add(new Card
        {
            CardUId = cardId,
            ListUId = listId,
            Title = "Important card",
            UserUId = ownerId,
            Status = "Active"
        });
        context.SaveChanges();
    }

    private static Notification Notification(string id, string recipientId, NotificationType type, bool read) =>
        new()
        {
            NotiId = id,
            RecipientId = recipientId,
            Type = type,
            Title = id,
            Message = id,
            Read = read,
            CreatedAt = id switch
            {
                "n1" => DateTime.UtcNow.AddMinutes(-2),
                "n2" => DateTime.UtcNow.AddMinutes(-1),
                _ => DateTime.UtcNow
            }
        };

    private static IHubContext<NotificationHub> CreateHubContext()
    {
        var proxy = new Mock<IClientProxy>();
        proxy.Setup(p => p.SendCoreAsync(
                It.IsAny<string>(),
                It.IsAny<object?[]>(),
                It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        var clients = new Mock<IHubClients>();
        clients.Setup(c => c.Group(It.IsAny<string>())).Returns(proxy.Object);

        var hub = new Mock<IHubContext<NotificationHub>>();
        hub.SetupGet(h => h.Clients).Returns(clients.Object);
        return hub.Object;
    }

    private static TodoAppAPI.Interfaces.INotificationService CreateRecordingNotificationService(TodoDbContext context)
    {
        return new NotificationService(context, CreateHubContext());
    }
}
