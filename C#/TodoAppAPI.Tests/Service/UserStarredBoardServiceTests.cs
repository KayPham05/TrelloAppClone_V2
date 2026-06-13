using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests;

public class UserStarredBoardServiceTests
{
    [Fact]
    public async Task SetStarredBoard_adds_and_removes_user_star()
    {
        await using var context = CreateContext();
        SeedUser(context, "user-1");
        SeedBoard(context, "board-1", "user-1");
        await context.SaveChangesAsync();
        var service = new UserStarredBoardService(context);

        var starred = await service.SetStarredBoard("user-1", "board-1", true);

        Assert.True(starred);
        Assert.True(await context.UserStarredBoards.AnyAsync(x =>
            x.UserUId == "user-1" && x.BoardUId == "board-1"));

        var unstarred = await service.SetStarredBoard("user-1", "board-1", false);

        Assert.True(unstarred);
        Assert.False(await context.UserStarredBoards.AnyAsync(x =>
            x.UserUId == "user-1" && x.BoardUId == "board-1"));
    }

    [Fact]
    public async Task GetStarredBoards_returns_user_starred_boards_first_by_starred_at()
    {
        await using var context = CreateContext();
        SeedUser(context, "user-1");
        SeedBoard(context, "old-board", "user-1", "Old board");
        SeedBoard(context, "new-board", "user-1", "New board");
        context.UserStarredBoards.AddRange(
            new UserStarredBoard
            {
                UserStarredBoardUId = "star-old",
                UserUId = "user-1",
                BoardUId = "old-board",
                StarredAt = DateTime.UtcNow.AddMinutes(-10)
            },
            new UserStarredBoard
            {
                UserStarredBoardUId = "star-new",
                UserUId = "user-1",
                BoardUId = "new-board",
                StarredAt = DateTime.UtcNow
            });
        await context.SaveChangesAsync();
        var service = new UserStarredBoardService(context);

        var boards = await service.GetStarredBoardByUserUId("user-1");

        Assert.Equal(new[] { "new-board", "old-board" }, boards.Select(b => b.BoardUId).ToArray());
        Assert.All(boards, board => Assert.True(board.IsStarred));
    }

    [Fact]
    public async Task SetStarredBoard_rejects_board_the_user_cannot_access()
    {
        await using var context = CreateContext();
        SeedUser(context, "owner");
        SeedUser(context, "outsider");
        SeedBoard(context, "private-board", "owner", "Private board");
        await context.SaveChangesAsync();
        var service = new UserStarredBoardService(context);

        var result = await service.SetStarredBoard("outsider", "private-board", true);

        Assert.False(result);
        Assert.Empty(context.UserStarredBoards);
    }

    [Fact]
    public async Task SetStarredBoard_allows_workspace_owner_to_star_private_workspace_board()
    {
        await using var context = CreateContext();
        SeedUser(context, "owner");
        SeedUser(context, "creator");
        context.Workspaces.Add(new Workspace
        {
            WorkspaceUId = "workspace-1",
            Name = "Team",
            OwnerUId = "owner",
            Status = "Active"
        });
        context.WorkspaceMembers.Add(new WorkspaceMembers
        {
            WorkspaceMemberUId = "workspace-owner",
            WorkspaceUId = "workspace-1",
            UserUId = "owner",
            Role = RoleConstants.WorkspaceOwner
        });
        context.Boards.Add(new Board
        {
            BoardUId = "board-1",
            BoardName = "Private workspace board",
            UserUId = "creator",
            WorkspaceUId = "workspace-1",
            IsPersonal = false,
            Visibility = "Private",
            Status = "Active"
        });
        await context.SaveChangesAsync();
        var service = new UserStarredBoardService(context);

        var result = await service.SetStarredBoard("owner", "board-1", true);

        Assert.True(result);
        Assert.True(await context.UserStarredBoards.AnyAsync(x =>
            x.UserUId == "owner" && x.BoardUId == "board-1"));
    }

    [Fact]
    public async Task Recent_boards_include_starred_flag_for_the_requesting_user()
    {
        await using var context = CreateContext();
        SeedUser(context, "user-1");
        SeedBoard(context, "board-1", "user-1");
        context.UserRecentBoards.Add(new UserRecentBoard
        {
            UserRecentBoardUId = "recent-1",
            UserUId = "user-1",
            BoardUId = "board-1",
            LastVisitedAt = DateTime.UtcNow
        });
        context.UserStarredBoards.Add(new UserStarredBoard
        {
            UserStarredBoardUId = "star-1",
            UserUId = "user-1",
            BoardUId = "board-1",
            StarredAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();
        var service = new UserBoardRecentService(context);

        var boards = await service.GetRecentBoardByUserUId("user-1");

        var board = Assert.Single(boards);
        Assert.True(board.IsStarred);
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new TodoDbContext(options);
    }

    private static void SeedUser(TodoDbContext context, string userId)
    {
        context.Users.Add(new User
        {
            UserUId = userId,
            UserName = userId,
            Email = $"{userId}@example.com",
            PasswordHash = "password"
        });
    }

    private static void SeedBoard(
        TodoDbContext context,
        string boardId,
        string ownerId,
        string name = "Board")
    {
        context.Boards.Add(new Board
        {
            BoardUId = boardId,
            BoardName = name,
            UserUId = ownerId,
            IsPersonal = true,
            Visibility = "Private",
            Status = "Active"
        });
    }
}
