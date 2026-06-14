using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using TodoAppAPI.Constants;
using Xunit;

namespace TodoAppAPI.Tests;

public class BoardServiceTests
{
    [Fact]
    public async Task AddBoardAsync_creates_default_lists_and_sample_cards_for_new_board()
    {
        await using var context = CreateContext();
        var service = new BoardService(context, new Mock<IAuthorizationService>().Object);

        var created = await service.AddBoardAsync(new Board
        {
            BoardName = "Onboarding board",
            UserUId = "owner-1",
            IsPersonal = true,
            Visibility = "Private"
        });

        Assert.NotNull(created);

        var lists = await context.Lists
            .Where(l => l.BoardUId == created!.BoardUId)
            .OrderBy(l => l.Position)
            .ToListAsync();

        Assert.Equal(new[] { "Chưa làm", "Đang làm", "Hoàn thành" }, lists.Select(l => l.ListName).ToArray());
        Assert.Equal(new[] { 0, 1, 2 }, lists.Select(l => l.Position).ToArray());
        Assert.All(lists, list => Assert.Equal("Active", list.Status));

        var cards = await context.Todos
            .Where(c => c.ListUId != null && lists.Select(l => l.ListUId).Contains(c.ListUId))
            .OrderBy(c => c.Position)
            .ToListAsync();

        Assert.Equal(3, cards.Count);
        Assert.All(cards, card => Assert.Equal("owner-1", card.UserUId));
        Assert.Contains(cards, card => card.Title == "Tạo thẻ đầu tiên của bạn" && card.Status == CardStatusValues.ToDo && card.ListUId == lists[0].ListUId);
        Assert.Contains(cards, card => card.Title == "Kéo thẻ này sang cột Đang làm" && card.Status == CardStatusValues.ToDo && card.ListUId == lists[1].ListUId);
        Assert.Contains(cards, card => card.Title == "Chuyển thẻ đã xong vào đây" && card.Status == CardStatusValues.Completed && card.ListUId == lists[2].ListUId);
    }

    [Fact]
    public async Task GetWorkspaceBoards_allows_workspace_owner_to_see_private_boards_without_board_membership()
    {
        await using var context = CreateContext();
        SeedWorkspace(context, "ws-1", "owner");
        context.WorkspaceMembers.Add(new WorkspaceMembers
        {
            WorkspaceMemberUId = "wm-owner",
            WorkspaceUId = "ws-1",
            UserUId = "owner",
            Role = RoleConstants.WorkspaceOwner
        });
        context.Boards.Add(new Board
        {
            BoardUId = "private-board",
            BoardName = "Private plan",
            WorkspaceUId = "ws-1",
            UserUId = "creator",
            Visibility = "Private"
        });
        await context.SaveChangesAsync();
        var service = CreateWorkspaceService(context);

        var boards = await service.GetWorkspaceBoards("ws-1", "owner");

        Assert.Contains(boards, b => b.BoardUId == "private-board");
    }

    [Fact]
    public async Task GetWorkspaceBoards_hides_workspace_boards_from_non_workspace_members()
    {
        await using var context = CreateContext();
        SeedWorkspace(context, "ws-1", "owner");
        context.Boards.Add(new Board
        {
            BoardUId = "private-board",
            BoardName = "Private plan",
            WorkspaceUId = "ws-1",
            UserUId = "owner",
            Visibility = "Private"
        });
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "bm-outsider",
            BoardUId = "private-board",
            UserUId = "outsider",
            BoardRole = RoleConstants.BoardViewer
        });
        await context.SaveChangesAsync();
        var service = CreateWorkspaceService(context);

        var boards = await service.GetWorkspaceBoards("ws-1", "outsider");

        Assert.Empty(boards);
    }

    [Fact]
    public async Task GetAllWorkspaces_hides_private_boards_from_workspace_member_without_board_membership()
    {
        await using var context = CreateContext();
        SeedUsers(context, "owner", "member");
        var member = new WorkspaceMembers
        {
            WorkspaceMemberUId = "wm-member",
            WorkspaceUId = "ws-1",
            UserUId = "member",
            Role = RoleConstants.WorkspaceMember
        };
        var publicBoard = new Board
        {
            BoardUId = "public-board",
            BoardName = "Public plan",
            WorkspaceUId = "ws-1",
            UserUId = "owner",
            Visibility = "Public"
        };
        var privateBoard = new Board
        {
            BoardUId = "private-board",
            BoardName = "Private plan",
            WorkspaceUId = "ws-1",
            UserUId = "owner",
            Visibility = "Private"
        };
        context.Workspaces.Add(new Workspace
        {
            WorkspaceUId = "ws-1",
            Name = "Team",
            OwnerUId = "owner",
            Status = "Active",
            Members = new List<WorkspaceMembers> { member },
            Boards = new List<Board> { publicBoard, privateBoard }
        });
        context.WorkspaceMembers.Add(member);
        context.Boards.AddRange(publicBoard, privateBoard);
        await context.SaveChangesAsync();
        var service = CreateWorkspaceService(context);

        var workspaces = await service.GetAllWorkspaces("member");

        var workspace = Assert.Single(workspaces);
        Assert.Contains(workspace.Boards, b => b.BoardUId == "public-board");
        Assert.DoesNotContain(workspace.Boards, b => b.BoardUId == "private-board");
    }

    [Fact]
    public async Task GetAllWorkspaces_allows_private_board_when_workspace_member_is_board_member()
    {
        await using var context = CreateContext();
        SeedUsers(context, "owner", "member");
        var member = new WorkspaceMembers
        {
            WorkspaceMemberUId = "wm-member",
            WorkspaceUId = "ws-1",
            UserUId = "member",
            Role = RoleConstants.WorkspaceViewer
        };
        var privateBoard = new Board
        {
            BoardUId = "private-board",
            BoardName = "Private plan",
            WorkspaceUId = "ws-1",
            UserUId = "owner",
            Visibility = "Private"
        };
        context.Workspaces.Add(new Workspace
        {
            WorkspaceUId = "ws-1",
            Name = "Team",
            OwnerUId = "owner",
            Status = "Active",
            Members = new List<WorkspaceMembers> { member },
            Boards = new List<Board> { privateBoard }
        });
        context.WorkspaceMembers.Add(member);
        context.Boards.Add(privateBoard);
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "bm-member",
            BoardUId = "private-board",
            UserUId = "member",
            BoardRole = RoleConstants.BoardViewer
        });
        await context.SaveChangesAsync();
        var service = CreateWorkspaceService(context);

        var workspaces = await service.GetAllWorkspaces("member");

        var workspace = Assert.Single(workspaces);
        Assert.Contains(workspace.Boards, b => b.BoardUId == "private-board");
    }

    [Fact]
    public async Task UpdateBoardAsync_allows_workspace_owner_uid_to_change_visibility()
    {
        await using var context = CreateContext();
        SeedWorkspace(context, "ws-1", "owner");
        context.Boards.Add(new Board
        {
            BoardUId = "board-1",
            BoardName = "Roadmap",
            WorkspaceUId = "ws-1",
            UserUId = "creator",
            Visibility = "Private"
        });
        await context.SaveChangesAsync();
        var service = new BoardService(context, new AuthorizationService(context));

        var result = await service.UpdateBoardAsync(new Board
        {
            BoardUId = "board-1",
            BoardName = "Roadmap",
            Visibility = "Public"
        }, "owner");

        Assert.True(result);
        Assert.Equal("Public", (await context.Boards.FindAsync("board-1"))!.Visibility);
    }

    [Fact]
    public async Task UpdateBoardAsync_preserves_background_when_renaming_without_background()
    {
        await using var context = CreateContext();
        SeedWorkspace(context, "ws-1", "owner");
        context.Boards.Add(new Board
        {
            BoardUId = "board-1",
            BoardName = "Roadmap",
            WorkspaceUId = "ws-1",
            UserUId = "owner",
            Visibility = "Private",
            BackgroundUrl = "https://cdn.example.com/board.jpg"
        });
        await context.SaveChangesAsync();
        var service = new BoardService(context, new AuthorizationService(context));

        var result = await service.UpdateBoardAsync(new Board
        {
            BoardUId = "board-1",
            BoardName = "New roadmap"
        }, "owner");

        var updated = await context.Boards.FindAsync("board-1");
        Assert.True(result);
        Assert.Equal("New roadmap", updated!.BoardName);
        Assert.Equal("https://cdn.example.com/board.jpg", updated.BackgroundUrl);
        Assert.Equal("Private", updated.Visibility);
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new TodoDbContext(options);
    }

    private static void SeedWorkspace(TodoDbContext context, string workspaceId, string ownerId)
    {
        context.Workspaces.Add(new Workspace
        {
            WorkspaceUId = workspaceId,
            Name = "Team",
            OwnerUId = ownerId,
            Status = "Active"
        });
    }

    private static void SeedUsers(TodoDbContext context, params string[] userIds)
    {
        foreach (var userId in userIds)
        {
            context.Users.Add(new User
            {
                UserUId = userId,
                UserName = userId,
                Email = $"{userId}@example.com",
                PasswordHash = "password"
            });
        }
    }

    private static WorkspaceService CreateWorkspaceService(TodoDbContext context)
    {
        return new WorkspaceService(
            context,
            new AuthorizationService(context),
            new Mock<INotificationService>().Object);
    }
}
