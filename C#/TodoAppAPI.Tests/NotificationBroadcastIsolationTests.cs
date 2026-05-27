using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Hubs;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests;

public class NotificationBroadcastIsolationTests
{
    [Fact]
    public async Task CreateManyInternalAsync_keeps_saved_notifications_when_signalr_broadcast_fails()
    {
        await using var context = CreateContext();
        SeedUsers(context, "recipient");
        var service = new NotificationService(context, CreateThrowingHubContext());

        var created = await service.CreateManyInternalAsync(new[]
        {
            new NotificationDTO
            {
                RecipientId = "recipient",
                Type = NotificationType.DueDateReminder,
                Title = "Card due soon",
                Message = "Card is due soon.",
                CardId = "card-1",
                Link = "/card-detail/card-1"
            }
        });

        Assert.Single(created);
        var saved = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.DueDateReminder, saved.Type);
        Assert.Equal("recipient", saved.RecipientId);
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

    private static IHubContext<NotificationHub> CreateThrowingHubContext()
    {
        var proxy = new Mock<IClientProxy>();
        proxy.Setup(p => p.SendCoreAsync(
                It.IsAny<string>(),
                It.IsAny<object?[]>(),
                It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("signalr unavailable"));

        var clients = new Mock<IHubClients>();
        clients.Setup(c => c.Group(It.IsAny<string>())).Returns(proxy.Object);

        var hub = new Mock<IHubContext<NotificationHub>>();
        hub.SetupGet(h => h.Clients).Returns(clients.Object);
        return hub.Object;
    }
}
