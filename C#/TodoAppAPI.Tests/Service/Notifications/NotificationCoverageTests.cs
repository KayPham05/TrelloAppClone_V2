using System.Security.Claims;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Moq;
using TodoAppAPI.Controllers;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using TodoAppAPI.Services;
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
            Notification("n5", "user-1", NotificationType.Assign, true),
            Notification("n6", "user-1", NotificationType.Move, false),
            Notification("n7", "user-1", NotificationType.CardArchived, false),
            Notification("n8", "user-1", NotificationType.AttachmentAdded, false),
            Notification("n9", "user-1", NotificationType.AttachmentRemoved, false),
            Notification("n10", "user-1", NotificationType.CardRenamed, false));
        await context.SaveChangesAsync();
        var service = new NotificationService(context, CreateHubContext());

        var page = await service.GetNotificationsAsync("user-1", NotificationTab.SentToMe, 1, 20);

        Assert.Equal(
            new[] { "n1", "n2", "n3", "n6", "n7", "n8", "n9", "n10" }.OrderBy(id => id),
            page.Items.Select(i => i.NotiId).OrderBy(id => id));
        Assert.DoesNotContain(page.Items, i => i.NotiId is "n4" or "n5");
        Assert.Equal(8, page.UnreadCount);
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
        SetUserName(context, "actor", "Nguyễn An");
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
        Assert.Equal(2, notifications.Count);
        Assert.Equal("member", notifications[0].RecipientId);
        Assert.Equal(NotificationType.Mention, notifications[0].Type);
        Assert.Equal("Nguyễn An đã nhắc đến bạn trong Important card.", notifications[0].Message);
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

        var notifications = await context.Notifications.ToListAsync();
        Assert.Equal(2, notifications.Count);
        Assert.Single(notifications, n => n.Type == NotificationType.Comment);
        Assert.Single(notifications, n => n.Type == NotificationType.Mention);
    }

    [Fact]
    public async Task CommentService_AddCommentAsync_notifies_assignees_when_comment_has_no_mentions()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member", "other");
        SetUserName(context, "actor", "Nguyá»…n An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "actor", "member", "other");
        await context.SaveChangesAsync();
        var service = new CommentService(context, CreateRecordingNotificationService(context));

        await service.AddCommentAsync(new Comment
        {
            CardUId = "card-1",
            UserUId = "actor",
            Content = "please review"
        });

        var notifications = await context.Notifications.ToListAsync();
        Assert.Equal(2, notifications.Count);
        Assert.All(notifications, n => Assert.Equal(NotificationType.Comment, n.Type));
        Assert.DoesNotContain(notifications, n => n.RecipientId == "actor");
        Assert.Contains(notifications, n => n.RecipientId == "member");
        Assert.Contains(notifications, n => n.RecipientId == "other");
    }

    [Fact]
    public async Task CommentService_AddCommentAsync_matches_full_email_mentions_with_plus_address()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        context.Users.Single(u => u.UserUId == "member").Email = "member+qa@example.com";
        SetUserName(context, "actor", "Nguyá»…n An");
        SetUserName(context, "member", "Display Member");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "member");
        await context.SaveChangesAsync();
        var service = new CommentService(context, CreateRecordingNotificationService(context));

        await service.AddCommentAsync(new Comment
        {
            CardUId = "card-1",
            UserUId = "actor",
            Content = "@member+qa@example.com please review"
        });

        var notifications = await context.Notifications.ToListAsync();
        Assert.Contains(notifications, n => n.RecipientId == "member" && n.Type == NotificationType.Mention);
        Assert.Contains(notifications, n => n.RecipientId == "member" && n.Type == NotificationType.Comment);
    }

    [Fact]
    public async Task CardMemberService_AddCardMember_creates_vietnamese_assignment_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "bm-actor",
            BoardUId = "board-1",
            UserUId = "actor",
            BoardRole = "Owner"
        });
        await context.SaveChangesAsync();
        var service = new CardMemberService(context, CreateRecordingNotificationService(context));

        var result = await service.AddCardMember("target", "actor", "board-1", "card-1");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.Assign, notification.Type);
        Assert.Equal("Bạn đã được Nguyễn An phân công vào Important card.", notification.Message);
    }

    [Fact]
    public async Task CardMemberService_RemoveCardMember_creates_vietnamese_unassigned_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "bm-actor",
            BoardUId = "board-1",
            UserUId = "actor",
            BoardRole = "Owner"
        });
        context.CardMembers.Add(new CardMember
        {
            CardMemberUId = "cm-target",
            CardUId = "card-1",
            UserUId = "target",
            Role = "Assignee"
        });
        await context.SaveChangesAsync();
        var service = new CardMemberService(context, CreateRecordingNotificationService(context));

        var result = await service.RemoveCardMember("target", "actor", "board-1", "card-1");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.CardUnassigned, notification.Type);
        Assert.Equal("Bạn đã bị Nguyễn An xóa khỏi Important card.", notification.Message);
    }

    [Fact]
    public async Task CardsService_ArchiveCardAsync_notifies_assignees_except_actor_in_vietnamese()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "actor", "member");
        var service = CreateCardsService(context);

        var result = await service.ArchiveCardAsync("card-1", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal("member", notification.RecipientId);
        Assert.Equal(NotificationType.CardArchived, notification.Type);
        Assert.Equal("Nguyễn An đã lưu trữ Important card", notification.Message);
    }

    [Fact]
    public async Task CardsService_AddFileToCardAsync_uses_file_name_in_vietnamese_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "member");
        var service = CreateCardsService(context);

        var result = await service.AddFileToCardAsync("card-1", "https://files.test/spec.pdf", "spec.pdf", "actor");

        Assert.NotNull(result.FileUrl);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.AttachmentAdded, notification.Type);
        Assert.Equal("Nguyễn An đã thêm một đính kèm spec.pdf vào Important card.", notification.Message);
    }

    [Fact]
    public async Task CardsService_DeleteAttachmentAsync_uses_deleted_file_name_in_vietnamese_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "member");
        context.FileUrls.Add(new FileUrl
        {
            FileUId = "file-1",
            CardUId = "card-1",
            Url = "https://files.test/delete.pdf",
            FileName = "delete.pdf"
        });
        await context.SaveChangesAsync();
        var service = CreateCardsService(context);

        var result = await service.DeleteAttachmentAsync("file-1", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.AttachmentRemoved, notification.Type);
        Assert.Equal("Nguyễn An đã xóa một đính kèm delete.pdf khỏi Important card.", notification.Message);
    }

    [Fact]
    public async Task CardsService_UpdateCard_notifies_assignees_when_card_is_renamed()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "member");
        var service = CreateCardsService(context);

        var result = await service.UpdateCard(new Card
        {
            CardUId = "card-1",
            ListUId = "list-1",
            Title = "Updated card",
            Status = "Active"
        }, "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.CardRenamed, notification.Type);
        Assert.Equal("Nguyễn An đã đổi tên Important card thành Updated card.", notification.Message);
    }

    [Fact]
    public async Task CardsService_UpdateListUid_notifies_assignees_when_card_moves_lists()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        context.Lists.Add(new ModelList { ListUId = "list-2", BoardUId = "board-1", ListName = "Done" });
        SeedCardMembers(context, "card-1", "member");
        await context.SaveChangesAsync();
        var service = CreateCardsService(context);

        var result = await service.UpdateListUid("card-1", "list-2", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.Move, notification.Type);
        Assert.Equal("Nguyễn An đã chuyển Important card sang Done.", notification.Message);
    }

    [Fact]
    public async Task CardsService_UpdateDueDateAsync_creates_vietnamese_due_date_changed_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "member");
        SetUserName(context, "actor", "Nguyễn An");
        SeedBoardListAndCard(context, "board-1", "list-1", "card-1", "actor");
        SeedCardMembers(context, "card-1", "member");
        var service = CreateCardsService(context);
        var dueDate = DateTime.UtcNow.AddDays(1);

        var result = await service.UpdateDueDateAsync("card-1", dueDate, "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.DueDateChanged, notification.Type);
        Assert.Equal($"Nguyễn An đã đổi hạn của Important card thành {dueDate:yyyy-MM-dd HH:mm}.", notification.Message);
    }

    [Fact]
    public async Task WorkspaceService_UpdateMemberRole_creates_vietnamese_role_change_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        context.Workspaces.Add(new Workspace { WorkspaceUId = "ws-1", Name = "Team Space", OwnerUId = "actor" });
        context.WorkspaceMembers.AddRange(
            new WorkspaceMembers { WorkspaceMemberUId = "wm-actor", WorkspaceUId = "ws-1", UserUId = "actor", Role = "Owner" },
            new WorkspaceMembers { WorkspaceMemberUId = "wm-target", WorkspaceUId = "ws-1", UserUId = "target", Role = "Member" });
        await context.SaveChangesAsync();
        var auth = CreateAllowingAuth();
        var service = new WorkspaceService(context, auth.Object, CreateRecordingNotificationService(context));

        var result = await service.UpdateMemberRole("ws-1", "target", "Admin", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.WorkspaceRoleChanged, notification.Type);
        Assert.Equal("Nguyễn An đã thay đổi vai trò của bạn từ Thành viên -> Quản trị viên", notification.Message);
    }

    [Fact]
    public async Task WorkspaceService_InviteUserToWorkspace_creates_vietnamese_add_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        context.Workspaces.Add(new Workspace { WorkspaceUId = "ws-1", Name = "Team Space", OwnerUId = "actor" });
        await context.SaveChangesAsync();
        var auth = CreateAllowingAuth();
        var service = new WorkspaceService(context, auth.Object, CreateRecordingNotificationService(context));

        var result = await service.InviteUserToWorkspace("ws-1", "target", "actor", "Member");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.WorkspaceMemberAdded, notification.Type);
        Assert.Equal("Bạn đã được Nguyễn An thêm vào Team Space.", notification.Message);
    }

    [Fact]
    public async Task WorkspaceService_RemoveMemberFromWorkspace_creates_vietnamese_remove_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        context.Workspaces.Add(new Workspace { WorkspaceUId = "ws-1", Name = "Team Space", OwnerUId = "actor" });
        context.WorkspaceMembers.AddRange(
            new WorkspaceMembers { WorkspaceMemberUId = "wm-actor", WorkspaceUId = "ws-1", UserUId = "actor", Role = "Owner" },
            new WorkspaceMembers { WorkspaceMemberUId = "wm-target", WorkspaceUId = "ws-1", UserUId = "target", Role = "Member" });
        await context.SaveChangesAsync();
        var auth = CreateAllowingAuth();
        var service = new WorkspaceService(context, auth.Object, CreateRecordingNotificationService(context));

        var result = await service.RemoveMemberFromWorkspace("ws-1", "target", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.WorkspaceMemberRemoved, notification.Type);
        Assert.Equal("Bạn đã bị Nguyễn An xóa khỏi Team Space.", notification.Message);
    }

    [Fact]
    public async Task BoardMemberService_UpdateBoardMemberRoleAsync_creates_vietnamese_role_change_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Sprint Board", UserUId = "actor" });
        context.BoardMembers.AddRange(
            new BoardMember { BoardMemberUId = "bm-actor", BoardUId = "board-1", UserUId = "actor", BoardRole = "Owner" },
            new BoardMember { BoardMemberUId = "bm-target", BoardUId = "board-1", UserUId = "target", BoardRole = "Viewer" });
        await context.SaveChangesAsync();
        var auth = CreateAllowingAuth();
        var service = new BoardMemberService(context, auth.Object, CreateRecordingNotificationService(context));

        var result = await service.UpdateBoardMemberRoleAsync("board-1", "target", "Editor", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.BoardRoleChanged, notification.Type);
        Assert.Equal("Nguyễn An đã thay đổi vai trò của bạn trong Sprint Board từ Người xem -> Biên tập viên", notification.Message);
    }

    [Fact]
    public async Task BoardMemberService_AddBoardMemberAsync_creates_vietnamese_add_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Sprint Board", UserUId = "actor" });
        await context.SaveChangesAsync();
        var auth = CreateAllowingAuth();
        var service = new BoardMemberService(context, auth.Object, CreateRecordingNotificationService(context));

        var result = await service.AddBoardMemberAsync("board-1", "target", "actor", "Editor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.BoardMemberAdded, notification.Type);
        Assert.Equal("Bạn đã được Nguyễn An thêm vào Sprint Board.", notification.Message);
    }

    [Fact]
    public async Task BoardMemberService_RemoveBoardMemberAsync_creates_vietnamese_remove_notification()
    {
        await using var context = CreateContext();
        SeedUsers(context, "actor", "target");
        SetUserName(context, "actor", "Nguyễn An");
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Sprint Board", UserUId = "actor" });
        context.BoardMembers.AddRange(
            new BoardMember { BoardMemberUId = "bm-actor", BoardUId = "board-1", UserUId = "actor", BoardRole = "Owner" },
            new BoardMember { BoardMemberUId = "bm-target", BoardUId = "board-1", UserUId = "target", BoardRole = "Viewer" });
        await context.SaveChangesAsync();
        var auth = CreateAllowingAuth();
        var service = new BoardMemberService(context, auth.Object, CreateRecordingNotificationService(context));

        var result = await service.RemoveBoardMemberAsync("board-1", "target", "actor");

        Assert.True(result);
        var notification = Assert.Single(await context.Notifications.ToListAsync());
        Assert.Equal(NotificationType.BoardMemberRemoved, notification.Type);
        Assert.Equal("Bạn đã bị Nguyễn An xóa khỏi Sprint Board.", notification.Message);
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .ConfigureWarnings(warnings => warnings.Ignore(InMemoryEventId.TransactionIgnoredWarning))
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

    private static void SetUserName(TodoDbContext context, string userId, string userName)
    {
        context.Users.Single(u => u.UserUId == userId).UserName = userName;
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

    private static void SeedCardMembers(TodoDbContext context, string cardId, params string[] userIds)
    {
        foreach (var userId in userIds)
        {
            context.CardMembers.Add(new CardMember
            {
                CardMemberUId = $"cm-{cardId}-{userId}",
                CardUId = cardId,
                UserUId = userId,
                Role = "Assignee"
            });
        }
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

    private static CardsService CreateCardsService(TodoDbContext context)
    {
        var reminderService = new Mock<ICardDueDateReminderService>();
        return new CardsService(
            context,
            CreateAllowingAuth().Object,
            CreateRecordingNotificationService(context),
            reminderService.Object);
    }

    private static Mock<IAuthorizationService> CreateAllowingAuth()
    {
        var auth = new Mock<IAuthorizationService>();
        auth.Setup(a => a.CanEditCardAsync(It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync(true);
        auth.Setup(a => a.CanManageWorkspaceMembersAsync(It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync(true);
        auth.Setup(a => a.CanUpdateMemberRoleAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync(true);
        auth.Setup(a => a.CanManageBoardMembersAsync(It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync(true);
        auth.Setup(a => a.GetUserRoleAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>())).ReturnsAsync("Owner");
        auth.Setup(a => a.LogPermissionChangeAsync(
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string?>(),
                It.IsAny<string?>()))
            .Returns(Task.CompletedTask);
        return auth;
    }
}
