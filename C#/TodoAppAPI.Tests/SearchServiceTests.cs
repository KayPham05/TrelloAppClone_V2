using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests;

public class SearchServiceTests
{
    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(System.Guid.NewGuid().ToString())
            .Options;
        return new TodoDbContext(options);
    }

    [Fact]
    public async Task SearchBoardsAndCardsAsync_ReturnsEmpty_WhenQueryIsNullOrWhiteSpace()
    {
        // Arrange
        await using var context = CreateContext();
        var service = new SearchService(context);

        // Act
        var result1 = await service.SearchBoardsAndCardsAsync("", "user-1");
        var result2 = await service.SearchBoardsAndCardsAsync("   ", "user-1");
        var result3 = await service.SearchBoardsAndCardsAsync(null!, "user-1");

        // Assert
        Assert.Empty(result1.Boards);
        Assert.Empty(result1.Cards);
        Assert.Empty(result2.Boards);
        Assert.Empty(result2.Cards);
        Assert.Empty(result3.Boards);
        Assert.Empty(result3.Cards);
    }

    [Fact]
    public async Task SearchBoardsAndCardsAsync_FindsBoardByOwner()
    {
        // Arrange
        await using var context = CreateContext();
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Project Alpha", UserUId = "user-1" });
        context.Boards.Add(new Board { BoardUId = "board-2", BoardName = "Project Beta", UserUId = "user-2" });
        await context.SaveChangesAsync();

        var service = new SearchService(context);

        // Act
        var result = await service.SearchBoardsAndCardsAsync("alpha", "user-1");

        // Assert
        Assert.Single(result.Boards);
        Assert.Equal("board-1", result.Boards.First().BoardUId);
        Assert.Empty(result.Cards);
    }

    [Fact]
    public async Task SearchBoardsAndCardsAsync_FindsBoardByMember()
    {
        // Arrange
        await using var context = CreateContext();
        
        var board = new Board { BoardUId = "board-1", BoardName = "Project Gamma", UserUId = "user-2" };
        context.Boards.Add(board);
        context.BoardMembers.Add(new BoardMember { BoardUId = "board-1", UserUId = "user-1", BoardRole = "Member" });
        await context.SaveChangesAsync();

        var service = new SearchService(context);

        // Act
        var result = await service.SearchBoardsAndCardsAsync("gamma", "user-1");

        // Assert
        Assert.Single(result.Boards);
        Assert.Equal("board-1", result.Boards.First().BoardUId);
    }

    [Fact]
    public async Task SearchBoardsAndCardsAsync_FindsCardByOwner()
    {
        // Arrange
        await using var context = CreateContext();
        
        context.Todos.Add(new Card { CardUId = "card-1", Title = "Fix login bug", UserUId = "user-1", Status = "Active" });
        context.Todos.Add(new Card { CardUId = "card-2", Title = "Fix logout bug", UserUId = "user-2", Status = "Active" });
        await context.SaveChangesAsync();

        var service = new SearchService(context);

        // Act
        var result = await service.SearchBoardsAndCardsAsync("login", "user-1");

        // Assert
        Assert.Single(result.Cards);
        Assert.Equal("card-1", result.Cards.First().CardUId);
        Assert.Empty(result.Boards);
    }

    [Fact]
    public async Task SearchBoardsAndCardsAsync_FindsCardByBoardMember()
    {
        // Arrange
        await using var context = CreateContext();
        
        var board = new Board { BoardUId = "board-1", BoardName = "Shared Board", UserUId = "user-2" };
        var list = new Models.List { ListUId = "list-1", BoardUId = "board-1", ListName = "To Do", Board = board };
        
        context.Boards.Add(board);
        context.Lists.Add(list);
        context.BoardMembers.Add(new BoardMember { BoardUId = "board-1", UserUId = "user-1", BoardRole = "Member", Board = board });
        
        context.Todos.Add(new Card { CardUId = "card-1", Title = "Shared task", UserUId = "user-2", ListUId = "list-1", List = list, Status = "Active" });
        await context.SaveChangesAsync();

        var service = new SearchService(context);

        // Act
        var result = await service.SearchBoardsAndCardsAsync("shared", "user-1");

        // Assert
        Assert.Single(result.Cards);
        Assert.Equal("card-1", result.Cards.First().CardUId);
        Assert.Equal("board-1", result.Cards.First().BoardUId);
    }

    [Fact]
    public async Task SearchBoardsAndCardsAsync_IsCaseInsensitive()
    {
        // Arrange
        await using var context = CreateContext();
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "LOWERCASE BOARD", UserUId = "user-1" });
        context.Todos.Add(new Card { CardUId = "card-1", Title = "UPPERCASE TASK", UserUId = "user-1", Status = "Active" });
        await context.SaveChangesAsync();

        var service = new SearchService(context);

        // Act
        var result = await service.SearchBoardsAndCardsAsync("case", "user-1");

        // Assert
        Assert.Single(result.Boards);
        Assert.Single(result.Cards);
    }
}
