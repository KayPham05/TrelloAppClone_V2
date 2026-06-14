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

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new TodoDbContext(options);
    }
}
