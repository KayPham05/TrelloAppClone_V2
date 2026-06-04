using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests;

public class AnalysisAuthorizationServiceTests
{
    [Theory]
    [InlineData(RoleConstants.BoardOwner, true)]
    [InlineData(RoleConstants.BoardAdmin, true)]
    [InlineData(RoleConstants.BoardEditor, true)]
    [InlineData(RoleConstants.BoardViewer, false)]
    public async Task CanViewBoardAnalysisAsync_allows_only_owner_admin_or_editor(string role, bool expected)
    {
        await using var context = CreateContext();
        SeedBoardMember(context, role);
        var service = new AuthorizationService(context);

        var result = await service.CanViewBoardAnalysisAsync("board-1", "requester");

        Assert.Equal(expected, result);
    }

    [Fact]
    public async Task CanViewBoardAnalysisAsync_allows_workspace_admin_when_not_board_member()
    {
        await using var context = CreateContext();
        context.Workspaces.Add(new Workspace { WorkspaceUId = "workspace-1", Name = "Team", OwnerUId = "owner" });
        context.Boards.Add(new Board
        {
            BoardUId = "board-1",
            BoardName = "Board",
            WorkspaceUId = "workspace-1",
            UserUId = "owner"
        });
        context.WorkspaceMembers.Add(new WorkspaceMembers
        {
            WorkspaceMemberUId = "wm-1",
            WorkspaceUId = "workspace-1",
            UserUId = "requester",
            Role = RoleConstants.WorkspaceAdmin
        });
        await context.SaveChangesAsync();
        var service = new AuthorizationService(context);

        var result = await service.CanViewBoardAnalysisAsync("board-1", "requester");

        Assert.True(result);
    }

    [Fact]
    public async Task CanViewWorkspaceAnalysisAsync_allows_owner_or_admin()
    {
        await using var context = CreateContext();
        context.Workspaces.Add(new Workspace { WorkspaceUId = "ws-1", Name = "Team", OwnerUId = "owner" });
        context.WorkspaceMembers.Add(new WorkspaceMembers { WorkspaceMemberUId = "wm-1", WorkspaceUId = "ws-1", UserUId = "admin", Role = RoleConstants.WorkspaceAdmin });
        context.WorkspaceMembers.Add(new WorkspaceMembers { WorkspaceMemberUId = "wm-2", WorkspaceUId = "ws-1", UserUId = "member", Role = RoleConstants.WorkspaceMember });
        await context.SaveChangesAsync();
        var service = new AuthorizationService(context);

        Assert.True(await service.CanViewWorkspaceAnalysisAsync("ws-1", "admin"));
        Assert.False(await service.CanViewWorkspaceAnalysisAsync("ws-1", "member"));
        Assert.False(await service.CanViewWorkspaceAnalysisAsync("ws-missing", "admin"));
    }

    [Fact]
    public async Task CanViewCardAnalysisAsync_allows_board_members_and_inbox_owners()
    {
        await using var context = CreateContext();
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Board", UserUId = "owner" });
        context.Lists.Add(new ModelList { ListUId = "list-1", BoardUId = "board-1" });
        context.Todos.Add(new Card { CardUId = "card-1", ListUId = "list-1", Title = "Card" });
        context.Todos.Add(new Card { CardUId = "card-inbox", ListUId = null, Title = "Inbox Card" });
        context.UserInboxCards.Add(new UserInboxCard { UserInboxCardId = "uic-1", CardUId = "card-inbox", UserUId = "inbox-owner" });
        context.BoardMembers.Add(new BoardMember { BoardMemberUId = "bm-1", BoardUId = "board-1", UserUId = "board-admin", BoardRole = RoleConstants.BoardAdmin });
        
        await context.SaveChangesAsync();
        var service = new AuthorizationService(context);

        // Can view if board admin
        Assert.True(await service.CanViewCardAnalysisAsync("card-1", "board-admin"));
        // Cannot view if not in board
        Assert.False(await service.CanViewCardAnalysisAsync("card-1", "stranger"));
        // Can view inbox card if owner
        Assert.True(await service.CanViewCardAnalysisAsync("card-inbox", "inbox-owner"));
        // Cannot view inbox card if not owner
        Assert.False(await service.CanViewCardAnalysisAsync("card-inbox", "stranger"));
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new TodoDbContext(options);
    }

    private static void SeedBoardMember(TodoDbContext context, string role)
    {
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Board", UserUId = "owner" });
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "bm-1",
            BoardUId = "board-1",
            UserUId = "requester",
            BoardRole = role
        });
        context.SaveChanges();
    }
}
