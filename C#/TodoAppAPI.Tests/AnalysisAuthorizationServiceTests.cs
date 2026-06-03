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
