using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs.ProjectAnalysis;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using TodoAppAPI.Service.Gemini;
using Xunit;
using ModelList = TodoAppAPI.Models.List;

namespace TodoAppAPI.Tests;

public class GeminiAnalysisServiceTests
{
    [Fact]
    public async Task AnalyzeBoardAsync_merges_valid_gemini_json_with_metrics_and_filters_unknown_card_ids()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardEditor);
        var gemini = new FakeGeminiClient("""
        {
          "summary": "Board đang có tiến độ ổn nhưng còn một thẻ quá hạn.",
          "risks": [
            {
              "severity": "high",
              "title": "Thẻ quá hạn",
              "description": "Fix login bug đã quá hạn.",
              "relatedCardUIds": ["card-active", "unknown-card"]
            }
          ],
          "suggestions": [
            { "priority": "high", "title": "Xử lý bug", "description": "Ưu tiên card quá hạn." }
          ],
          "inferredMilestones": [
            { "name": "Hoàn tất checklist", "status": "atRisk", "description": "Checklist chưa hoàn tất." }
          ]
        }
        """);
        var service = CreateService(context, gemini);

        var result = await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Analysis);
        Assert.Equal("board", result.Analysis.ScopeType);
        Assert.Equal("board-1", result.Analysis.ScopeUId);
        Assert.Equal(2, result.Analysis.Metrics.TotalCards);
        Assert.Equal(1, result.Analysis.Metrics.CompletedCards);
        Assert.Equal(1, result.Analysis.Metrics.InProgressCards);
        Assert.Equal(1, result.Analysis.Metrics.OverdueCards);
        var risk = Assert.Single(result.Analysis.Risks);
        Assert.Equal(new[] { "card-active" }, risk.RelatedCardUIds);
        Assert.Single(result.Analysis.Suggestions);
        Assert.Single(result.Analysis.InferredMilestones);
        Assert.False(result.Analysis.Cached);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_rejects_viewer_role()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardViewer);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Forbidden, result.Status);
        Assert.Null(result.Analysis);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_returns_deterministic_fallback_when_gemini_json_is_invalid()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient("not-json"));

        var result = await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Analysis);
        Assert.Contains("hoàn thành", result.Analysis.Summary);
        Assert.Equal(2, result.Analysis.Metrics.TotalCards);
        Assert.NotEmpty(result.Analysis.Risks);
        Assert.NotEmpty(result.Analysis.Suggestions);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_force_refresh_bypasses_cache()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var gemini = new FakeGeminiClient("""{"summary":"cached test","risks":[],"suggestions":[],"inferredMilestones":[]}""");
        var service = CreateService(context, gemini);

        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        await service.AnalyzeBoardAsync("board-1", "requester", true, CancellationToken.None);

        Assert.Equal(2, gemini.Calls);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_returns_not_found_for_unknown_board()
    {
        await using var context = CreateContext();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeBoardAsync("missing-board", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.NotFound, result.Status);
        Assert.Null(result.Analysis);
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new TodoDbContext(options);
    }

    private static GeminiAnalysisService CreateService(TodoDbContext context, IGeminiClient geminiClient)
    {
        var settings = Options.Create(new GeminiSettings
        {
            ApiKey = "fake-key",
            Model = "gemini-test",
            CacheMinutes = 5,
            MaxRisks = 5,
            MaxSuggestions = 5
        });
        var auth = new AuthorizationService(context);
        return new GeminiAnalysisService(
            context,
            auth,
            geminiClient,
            new MemoryCache(new MemoryCacheOptions()),
            settings,
            NullLogger<GeminiAnalysisService>.Instance);
    }

    private static void SeedBoardWithCards(TodoDbContext context, string requesterRole)
    {
        var today = DateTime.UtcNow.Date;
        context.Users.AddRange(
            new User { UserUId = "owner", UserName = "owner", Email = "owner@example.com", PasswordHash = "hash", StatusAccount = "Active" },
            new User { UserUId = "requester", UserName = "requester", Email = "requester@example.com", PasswordHash = "hash", StatusAccount = "Active" });
        context.Boards.Add(new Board { BoardUId = "board-1", BoardName = "Sprint Board", UserUId = "owner" });
        context.BoardMembers.Add(new BoardMember
        {
            BoardMemberUId = "bm-requester",
            BoardUId = "board-1",
            UserUId = "requester",
            BoardRole = requesterRole
        });
        context.Lists.AddRange(
            new ModelList { ListUId = "list-active", BoardUId = "board-1", ListName = "In Progress", Position = 1 },
            new ModelList { ListUId = "list-done", BoardUId = "board-1", ListName = "Done", Position = 2 });
        context.Todos.AddRange(
            new Card
            {
                CardUId = "card-active",
                Title = "Fix login bug",
                UserUId = "owner",
                ListUId = "list-active",
                DueDate = today.AddDays(-1),
                Status = "Active",
                Position = 1
            },
            new Card
            {
                CardUId = "card-done",
                Title = "Ship onboarding",
                UserUId = "owner",
                ListUId = "list-done",
                DueDate = today.AddDays(-2),
                Status = "Completed",
                Position = 1
            });
        context.TodoItems.AddRange(
            new TodoItem { TodoItemUId = "todo-1", CardUId = "card-active", Content = "write test", IsCompleted = true },
            new TodoItem { TodoItemUId = "todo-2", CardUId = "card-active", Content = "fix bug", IsCompleted = false },
            new TodoItem { TodoItemUId = "todo-3", CardUId = "card-done", Content = "deploy", IsCompleted = true });
        context.SaveChanges();
    }

    private sealed class FakeGeminiClient : IGeminiClient
    {
        private readonly string _response;

        public FakeGeminiClient(string response)
        {
            _response = response;
        }

        public int Calls { get; private set; }

        public Task<string> GenerateJsonAsync(string prompt, object responseSchema, CancellationToken cancellationToken)
        {
            Calls++;
            return Task.FromResult(_response);
        }
    }
}
