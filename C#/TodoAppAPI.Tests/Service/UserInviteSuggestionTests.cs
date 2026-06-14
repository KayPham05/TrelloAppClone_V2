using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using TodoAppAPI.Data;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests;

public class UserInviteSuggestionTests
{
    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new TodoDbContext(options);
    }

    private static UserService CreateService(TodoDbContext context)
    {
        var emailService = new EmailService(new ConfigurationBuilder().Build());
        var jwtService = Mock.Of<IJwtService>();
        var logger = Mock.Of<ILogger<UserService>>();
        var memoryCache = new MemoryCache(new MemoryCacheOptions());
        var hub = Mock.Of<IHubContext<NotificationHub>>();
        return new UserService(context, emailService, jwtService, logger, memoryCache, hub);
    }

    private static User User(string id, string name, string email) => new()
    {
        UserUId = id,
        UserName = name,
        Email = email,
        PasswordHash = "hash",
        IsEmailVerified = true,
        StatusAccount = "Active"
    };

    [Fact]
    public async Task Workspace_scope_finds_registered_users_and_excludes_requester_and_existing_workspace_members()
    {
        await using var context = CreateContext();
        context.Users.AddRange(
            User("requester", "Owner User", "owner@example.com"),
            User("candidate", "Nguyen Van A", "nguyena@example.com"),
            User("member", "Nguyen Member", "member@example.com"));
        context.Workspaces.Add(new Workspace { WorkspaceUId = "workspace-1", Name = "Demo", OwnerUId = "requester" });
        context.WorkspaceMembers.Add(new WorkspaceMembers { WorkspaceUId = "workspace-1", UserUId = "member", Role = "Member" });
        await context.SaveChangesAsync();

        var service = CreateService(context);
        var result = await service.GetInviteSuggestionsAsync(
            query: "nguyen",
            scope: "workspace",
            requesterUId: "requester",
            workspaceId: "workspace-1",
            boardId: null);

        Assert.Single(result);
        Assert.Equal("candidate", result[0].UserUId);
        Assert.Equal("nguyena@example.com", result[0].Email);
    }

    [Fact]
    public async Task Board_scope_only_returns_workspace_members_and_excludes_existing_board_members()
    {
        await using var context = CreateContext();
        context.Users.AddRange(
            User("owner", "Owner", "owner@example.com"),
            User("workspace-member", "Nguyen Workspace", "workspace@example.com"),
            User("board-member", "Nguyen Board", "board@example.com"),
            User("outside", "Nguyen Outside", "outside@example.com"));
        context.Workspaces.Add(new Workspace { WorkspaceUId = "workspace-1", Name = "Demo", OwnerUId = "owner" });
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Board", WorkspaceUId = "workspace-1", UserUId = "owner" });
        context.WorkspaceMembers.AddRange(
            new WorkspaceMembers { WorkspaceUId = "workspace-1", UserUId = "workspace-member", Role = "Member" },
            new WorkspaceMembers { WorkspaceUId = "workspace-1", UserUId = "board-member", Role = "Member" });
        context.BoardMembers.Add(new BoardMember { BoardUId = "board-1", UserUId = "board-member", BoardRole = "Editor" });
        await context.SaveChangesAsync();

        var service = CreateService(context);
        var result = await service.GetInviteSuggestionsAsync(
            query: "nguyen",
            scope: "board",
            requesterUId: "owner",
            workspaceId: "workspace-1",
            boardId: "board-1");

        Assert.Single(result);
        Assert.Equal("workspace-member", result[0].UserUId);
        Assert.Equal("Member", result[0].WorkspaceRole);
    }

    [Fact]
    public async Task Invite_suggestions_returns_empty_for_short_query()
    {
        await using var context = CreateContext();
        context.Users.Add(User("candidate", "Nguyen Van A", "nguyena@example.com"));
        await context.SaveChangesAsync();

        var service = CreateService(context);
        var result = await service.GetInviteSuggestionsAsync("n", "workspace", "requester", null, null);

        Assert.Empty(result);
    }

    [Fact]
    public async Task Invite_suggestions_clamps_limit_between_one_and_twenty()
    {
        await using var context = CreateContext();
        for (var i = 0; i < 25; i++)
        {
            context.Users.Add(User($"candidate-{i}", $"Nguyen Candidate {i:00}", $"nguyen{i:00}@example.com"));
        }
        await context.SaveChangesAsync();

        var service = CreateService(context);

        var oneResult = await service.GetInviteSuggestionsAsync(
            query: "nguyen",
            scope: "workspace",
            requesterUId: "requester",
            workspaceId: null,
            boardId: null,
            limit: 0);
        var twentyResults = await service.GetInviteSuggestionsAsync(
            query: "nguyen",
            scope: "workspace",
            requesterUId: "requester",
            workspaceId: null,
            boardId: null,
            limit: 100);

        Assert.Single(oneResult);
        Assert.Equal(20, twentyResults.Count);
    }
}
