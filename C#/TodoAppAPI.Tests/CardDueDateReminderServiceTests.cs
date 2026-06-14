using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.SignalR;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using TodoAppAPI.Constants;
using Xunit;
using ModelList = TodoAppAPI.Models.List;

namespace TodoAppAPI.Tests;

public class CardDueDateReminderServiceTests
{
    [Fact]
    public async Task SendDueRemindersAsync_sends_one_day_reminder_once_per_assignee()
    {
        await using var context = CreateContext();
        var now = new DateTime(2026, 6, 1, 9, 0, 0);
        var dueDate = now.AddHours(2);
        SeedUsers(context, "owner", "assignee-1", "assignee-2");
        SeedCard(context, "card-1", "board-1", "list-1", "owner", dueDate, "Active", "assignee-1", "assignee-2");
        var service = CreateReminderService(context);

        await service.SendDueRemindersAsync(now);

        var notifications = await context.Notifications
            .OrderBy(n => n.RecipientId)
            .ToListAsync();
        Assert.Equal(new[] { "assignee-1", "assignee-2" }, notifications.Select(n => n.RecipientId).ToArray());
        Assert.All(notifications, n =>
        {
            Assert.Equal(NotificationType.DueDateReminder, n.Type);
            Assert.Equal("card-1", n.CardId);
            Assert.Equal("board-1", n.BoardId);
            Assert.Equal("list-1", n.ListId);
            Assert.Equal("/card-detail/card-1", n.Link);
        });

        var delivery = Assert.Single(await context.CardDueDateReminderDeliveries.ToListAsync());
        Assert.Equal("card-1", delivery.CardUId);
        Assert.Equal(DueDateReminderMilestone.OneDayBefore, delivery.Milestone);
        Assert.Equal(dueDate, delivery.DueDateSnapshot);
        Assert.Equal(now, delivery.SentAt);
    }

    [Fact]
    public async Task SendDueRemindersAsync_does_not_duplicate_existing_card_milestone()
    {
        await using var context = CreateContext();
        var now = new DateTime(2026, 6, 1, 9, 0, 0);
        SeedUsers(context, "owner", "assignee");
        SeedCard(context, "card-1", "board-1", "list-1", "owner", now.AddHours(2), "Active", "assignee");
        var service = CreateReminderService(context);

        await service.SendDueRemindersAsync(now);
        await service.SendDueRemindersAsync(now);

        Assert.Single(await context.Notifications.ToListAsync());
        Assert.Single(await context.CardDueDateReminderDeliveries.ToListAsync());
    }

    [Fact]
    public async Task SendDueRemindersAsync_sends_only_one_hour_milestone_inside_one_hour_window()
    {
        await using var context = CreateContext();
        var now = new DateTime(2026, 6, 1, 9, 0, 0);
        SeedUsers(context, "owner", "assignee");
        SeedCard(context, "card-1", "board-1", "list-1", "owner", now.AddMinutes(45), "Active", "assignee");
        var service = CreateReminderService(context);

        await service.SendDueRemindersAsync(now);

        var delivery = Assert.Single(await context.CardDueDateReminderDeliveries.ToListAsync());
        Assert.Equal(DueDateReminderMilestone.OneHourBefore, delivery.Milestone);
        Assert.Single(await context.Notifications.ToListAsync());
    }

    [Fact]
    public async Task SendDueRemindersAsync_sends_due_now_milestone_for_due_or_overdue_card()
    {
        await using var context = CreateContext();
        var now = new DateTime(2026, 6, 1, 9, 0, 0);
        SeedUsers(context, "owner", "assignee");
        SeedCard(context, "card-1", "board-1", "list-1", "owner", now.AddMinutes(-1), "Active", "assignee");
        var service = CreateReminderService(context);

        await service.SendDueRemindersAsync(now);

        var delivery = Assert.Single(await context.CardDueDateReminderDeliveries.ToListAsync());
        Assert.Equal(DueDateReminderMilestone.DueNow, delivery.Milestone);
        Assert.Single(await context.Notifications.ToListAsync());
    }

    [Fact]
    public async Task SendDueRemindersAsync_skips_completed_deleted_and_unassigned_cards()
    {
        await using var context = CreateContext();
        var now = new DateTime(2026, 6, 1, 9, 0, 0);
        SeedUsers(context, "owner", "assignee");
        SeedCard(context, "completed", "board-1", "list-1", "owner", now.AddHours(2), "Completed", "assignee");
        SeedCard(context, "hoan-thanh", "board-1", "list-1", "owner", now.AddHours(2), "hoan_thanh", "assignee");
        SeedCard(context, "unicode-completed", "board-1", "list-1", "owner", now.AddHours(2), "hoàn thành", "assignee");
        SeedCard(context, "deleted", "board-1", "list-1", "owner", now.AddHours(2), "Deleted", "assignee");
        SeedCard(context, "no-assignee", "board-1", "list-1", "owner", now.AddHours(2), "Active");
        var service = CreateReminderService(context);

        await service.SendDueRemindersAsync(now);

        Assert.Empty(await context.Notifications.ToListAsync());
        Assert.Empty(await context.CardDueDateReminderDeliveries.ToListAsync());
    }

    [Fact]
    public async Task CardsService_UpdateDueDateAsync_resets_reminder_history_when_due_date_changes_or_is_removed()
    {
        await using var context = CreateContext();
        var oldDueDate = DateTime.UtcNow.AddDays(2);
        SeedUsers(context, "owner", "assignee");
        SeedCard(context, "card-1", "board-1", "list-1", "owner", oldDueDate, CardStatusValues.ToDo, "assignee");
        context.CardDueDateReminderDeliveries.Add(Delivery("card-1", DueDateReminderMilestone.OneDayBefore, oldDueDate));
        await context.SaveChangesAsync();
        var auth = new Mock<IAuthorizationService>();
        auth.Setup(a => a.CanEditCardAsync("card-1", "owner")).ReturnsAsync(true);
        var service = CreateCardsService(context, auth.Object);

        var changed = await service.UpdateDueDateAsync("card-1", oldDueDate.AddHours(1), "owner");

        Assert.True(changed);
        Assert.Empty(await context.CardDueDateReminderDeliveries.ToListAsync());

        context.CardDueDateReminderDeliveries.Add(Delivery("card-1", DueDateReminderMilestone.OneHourBefore, oldDueDate.AddHours(1)));
        await context.SaveChangesAsync();

        var removed = await service.UpdateDueDateAsync("card-1", null, "owner");

        Assert.True(removed);
        Assert.Empty(await context.CardDueDateReminderDeliveries.ToListAsync());
    }

    [Fact]
    public async Task CardsService_UpdateCard_resets_history_only_when_due_date_changes()
    {
        await using var context = CreateContext();
        var dueDate = DateTime.UtcNow.AddDays(2);
        SeedUsers(context, "owner", "assignee");
        SeedCard(context, "card-1", "board-1", "list-1", "owner", dueDate, CardStatusValues.ToDo, "assignee");
        context.CardDueDateReminderDeliveries.Add(Delivery("card-1", DueDateReminderMilestone.OneDayBefore, dueDate));
        await context.SaveChangesAsync();
        var auth = new Mock<IAuthorizationService>();
        auth.Setup(a => a.CanEditCardAsync("card-1", "owner")).ReturnsAsync(true);
        var service = CreateCardsService(context, auth.Object);

        var unchanged = await service.UpdateCard(new Card
        {
            CardUId = "card-1",
            Title = "Updated title",
            Description = "Updated description",
            DueDate = dueDate,
            Position = 5,
            ListUId = "list-1",
            BackgroundUrl = "bg.png"
        }, "owner");

        Assert.True(unchanged);
        Assert.Single(await context.CardDueDateReminderDeliveries.ToListAsync());

        var changed = await service.UpdateCard(new Card
        {
            CardUId = "card-1",
            Title = "Updated title again",
            Description = "Updated description again",
            DueDate = dueDate.AddDays(1),
            Position = 6,
            ListUId = "list-1",
            BackgroundUrl = "bg-2.png"
        }, "owner");

        Assert.True(changed);
        Assert.Empty(await context.CardDueDateReminderDeliveries.ToListAsync());
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
            if (context.Users.Any(u => u.UserUId == id))
                continue;

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

    private static void SeedCard(
        TodoDbContext context,
        string cardId,
        string boardId,
        string listId,
        string ownerId,
        DateTime? dueDate,
        string status,
        params string[] assigneeIds)
    {
        if (!context.Boards.Any(b => b.BoardUId == boardId))
        {
            context.Boards.Add(new Board { BoardUId = boardId, BoardName = boardId, UserUId = ownerId });
        }

        if (!context.Lists.Any(l => l.ListUId == listId))
        {
            context.Lists.Add(new ModelList { ListUId = listId, BoardUId = boardId, ListName = listId });
        }

        context.Todos.Add(new Card
        {
            CardUId = cardId,
            ListUId = listId,
            Title = cardId,
            UserUId = ownerId,
            DueDate = dueDate,
            Status = status
        });

        foreach (var assigneeId in assigneeIds)
        {
            context.CardMembers.Add(new CardMember
            {
                CardMemberUId = $"{cardId}-{assigneeId}",
                CardUId = cardId,
                UserUId = assigneeId,
                Role = "Assignee"
            });
        }

        context.SaveChanges();
    }

    private static CardDueDateReminderDelivery Delivery(
        string cardId,
        DueDateReminderMilestone milestone,
        DateTime dueDateSnapshot) =>
        new()
        {
            ReminderDeliveryId = Guid.NewGuid().ToString(),
            CardUId = cardId,
            Milestone = milestone,
            DueDateSnapshot = dueDateSnapshot,
            SentAt = dueDateSnapshot.AddHours(-2)
        };

    private static CardDueDateReminderService CreateReminderService(TodoDbContext context)
    {
        return new CardDueDateReminderService(context, new NotificationService(context, CreateHubContext()));
    }

    private static CardsService CreateCardsService(TodoDbContext context, IAuthorizationService auth)
    {
        var notificationService = new NotificationService(context, CreateHubContext());
        var reminderService = new CardDueDateReminderService(context, notificationService);
        return new CardsService(context, auth, notificationService, reminderService);
    }

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
}
