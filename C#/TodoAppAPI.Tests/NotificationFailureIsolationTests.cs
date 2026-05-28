using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using TodoAppAPI.Services;
using Xunit;
using ModelList = TodoAppAPI.Models.List;

namespace TodoAppAPI.Tests;

public class NotificationFailureIsolationTests
{
    [Fact]
    public async Task CardMemberService_AddCardMember_returns_true_when_notification_throws_after_member_saved()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "board-member-owner",
            BoardUId = "board-1",
            UserUId = "actor",
            BoardRole = "Owner"
        });
        await context.SaveChangesAsync();

        var service = new CardMemberService(context, new ThrowingNotificationService());

        var result = await service.AddCardMember("target", "actor", "board-1", "card-1");

        Assert.True(result);
        Assert.True(await context.CardMembers.AnyAsync(cm => cm.CardUId == "card-1" && cm.UserUId == "target"));
    }

    [Fact]
    public async Task BoardMemberService_AddMember_returns_true_when_notification_throws_after_member_saved()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Roadmap", UserUId = "actor" });
        await context.SaveChangesAsync();

        var auth = new Mock<IAuthorizationService>();
        auth.Setup(a => a.CanManageBoardMembersAsync("board-1", "actor")).ReturnsAsync(true);
        auth.Setup(a => a.LogPermissionChangeAsync("board-1", "Board", "target", "actor", "AddMember", null, "Member"))
            .Returns(Task.CompletedTask);
        var service = new BoardMemberService(context, auth.Object, new ThrowingNotificationService());

        var result = await service.AddBoardMemberAsync("board-1", "target", "actor", "Member");

        Assert.True(result);
        Assert.True(await context.BoardMembers.AnyAsync(bm => bm.BoardUId == "board-1" && bm.UserUId == "target"));
    }

    [Fact]
    public async Task CardsService_UpdateDueDateAsync_returns_true_when_notification_throws_after_due_date_saved()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.CardMembers.Add(new CardMember
        {
            CardMemberUId = "member-1",
            CardUId = "card-1",
            UserUId = "target",
            Role = "Assignee"
        });
        await context.SaveChangesAsync();

        var auth = new Mock<IAuthorizationService>();
        auth.Setup(a => a.CanEditCardAsync("card-1", "actor")).ReturnsAsync(true);
        var reminderService = new Mock<ICardDueDateReminderService>();
        reminderService
            .Setup(r => r.ResetReminderHistoryAsync("card-1", It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        var service = new CardsService(context, auth.Object, new ThrowingNotificationService(), reminderService.Object);
        var dueDate = new DateTime(2026, 6, 1);

        var result = await service.UpdateDueDateAsync("card-1", dueDate, "actor");

        Assert.True(result);
        Assert.Equal(dueDate, (await context.Todos.FindAsync("card-1"))!.DueDate);
    }

    [Fact]
    public async Task CommentService_AddCommentAsync_returns_comment_when_mention_notification_throws_after_comment_saved()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.CardMembers.Add(new CardMember
        {
            CardMemberUId = "member-1",
            CardUId = "card-1",
            UserUId = "target",
            Role = "Assignee"
        });
        await context.SaveChangesAsync();

        var service = new CommentService(context, new ThrowingNotificationService());

        var result = await service.AddCommentAsync(new Comment
        {
            CardUId = "card-1",
            UserUId = "actor",
            Content = "@target please check this"
        });

        Assert.NotNull(result);
        Assert.True(await context.Comments.AnyAsync(c => c.CardUId == "card-1" && c.Content.Contains("@target")));
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

    private sealed class ThrowingNotificationService : INotificationService
    {
        public Task<NotificationPageDto> GetNotificationsAsync(string userId, NotificationTab tab, int page, int pageSize) =>
            throw new NotImplementedException();

        public Task<int> GetUnreadCountAsync(string userId) => throw new NotImplementedException();

        public Task<bool> MarkAsReadAsync(string userId, string notiId) => throw new NotImplementedException();

        public Task<int> MarkAllAsReadAsync(string userId) => throw new NotImplementedException();

        public Task<Notification?> CreateInternalAsync(NotificationDTO dto) =>
            throw new InvalidOperationException("notification failed");

        public Task<IReadOnlyList<Notification>> CreateManyInternalAsync(IEnumerable<NotificationDTO> dtos) =>
            throw new InvalidOperationException("notification failed");

        public Task<bool> DeleteAsync(string userId, string notiId) => throw new NotImplementedException();
    }
}
