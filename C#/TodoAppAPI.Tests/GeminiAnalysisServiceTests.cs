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
    public async Task AnalyzeBoardAsync_does_not_auto_persist_gemini_report()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardEditor);
        var service = CreateService(context, new FakeGeminiClient(ValidGeminiJson("history test")));

        var result = await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.Empty(context.AnalysisReports);
    }

    [Fact]
    public async Task SaveLatestReportAsync_persists_latest_gemini_report()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardEditor);
        var service = CreateService(context, new FakeGeminiClient(ValidGeminiJson("history test")));

        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        var result = await service.SaveLatestReportAsync("board", "board-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Report);
        var report = Assert.Single(context.AnalysisReports);
        Assert.Equal("board", report.ScopeType);
        Assert.Equal("board-1", report.ScopeUId);
        Assert.Equal("requester", report.GeneratedByUId);
        Assert.Equal("Sprint Board", report.Title);
        Assert.Equal("gemini-test", report.ModelUsed);
        Assert.Contains("history test", report.ReportData);
    }

    [Fact]
    public async Task SaveLatestReportAsync_does_not_persist_deterministic_fallback_report()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient("not-json"));

        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        var result = await service.SaveLatestReportAsync("board", "board-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.BadRequest, result.Status);
        Assert.Empty(context.AnalysisReports);
    }

    [Fact]
    public async Task SaveLatestReportAsync_can_save_cached_gemini_report()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient(ValidGeminiJson("cache test")));

        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        var saveResult = await service.SaveLatestReportAsync("board", "board-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, saveResult.Status);
        Assert.Single(context.AnalysisReports);
    }

    [Fact]
    public async Task SaveLatestReportAsync_keeps_latest_five_reports_per_scope()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient(ValidGeminiJson("retention test")));

        for (var i = 0; i < 6; i++)
        {
            await service.AnalyzeBoardAsync("board-1", "requester", true, CancellationToken.None);
            await service.SaveLatestReportAsync("board", "board-1", "requester", CancellationToken.None);
        }

        Assert.Equal(5, context.AnalysisReports.Count(r => r.ScopeType == "board" && r.ScopeUId == "board-1"));
    }

    [Fact]
    public async Task GetReportHistoryAsync_returns_page_for_authorized_user()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        context.AnalysisReports.AddRange(
            SavedReport("report-1", generatedAt: DateTime.UtcNow.AddMinutes(-2), progress: 40),
            SavedReport("report-2", generatedAt: DateTime.UtcNow.AddMinutes(-1), progress: 70));
        context.SaveChanges();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportHistoryAsync("board", "board-1", "requester", 1, 1, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Page);
        Assert.Single(result.Page.Items);
        Assert.Equal("report-2", result.Page.Items[0].ReportUId);
        Assert.True(result.Page.HasMore);
    }

    [Fact]
    public async Task GetReportByIdAsync_returns_saved_payload_for_authorized_user()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        context.AnalysisReports.Add(SavedReport("report-1", cached: true));
        context.SaveChanges();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportByIdAsync("report-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Analysis);
        Assert.Equal("board-1", result.Analysis.ScopeUId);
        Assert.False(result.Analysis.Cached);
    }

    [Fact]
    public async Task GetReportByIdAsync_returns_forbidden_for_unauthorized_user()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardViewer);
        context.AnalysisReports.Add(SavedReport("report-1"));
        context.SaveChanges();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportByIdAsync("report-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Forbidden, result.Status);
        Assert.Null(result.Analysis);
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
        Assert.Contains("quá hạn", result.Analysis.Summary);
        Assert.Equal(2, result.Analysis.Metrics.TotalCards);
        Assert.NotEmpty(result.Analysis.Risks);
        Assert.NotEmpty(result.Analysis.Suggestions);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_force_refresh_reuses_cache_when_snapshot_is_unchanged()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var gemini = new FakeGeminiClient("""{"summary":"cached test","risks":[],"suggestions":[],"inferredMilestones":[]}""");
        var service = CreateService(context, gemini);

        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        await service.AnalyzeBoardAsync("board-1", "requester", true, CancellationToken.None);

        Assert.Equal(1, gemini.Calls);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_force_refresh_calls_gemini_when_snapshot_changed()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var gemini = new FakeGeminiClient("""{"summary":"changed test","risks":[],"suggestions":[],"inferredMilestones":[]}""");
        var service = CreateService(context, gemini);

        await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);
        var card = await context.Todos.FirstAsync(c => c.CardUId == "card-active");
        card.Title = "Fix login bug after data changed";
        await context.SaveChangesAsync();
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

    [Fact]
    public async Task AnalyzeWorkspaceAsync_returns_success_for_authorized_user()
    {
        await using var context = CreateContext();
        SeedWorkspaceWithCards(context, requesterRole: RoleConstants.WorkspaceAdmin);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeWorkspaceAsync("workspace-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Analysis);
        Assert.Equal("workspace", result.Analysis.ScopeType);
        Assert.Equal("workspace-1", result.Analysis.ScopeUId);
    }

    [Fact]
    public async Task AnalyzeWorkspaceAsync_returns_forbidden_for_unauthorized_user()
    {
        await using var context = CreateContext();
        SeedWorkspaceWithCards(context, requesterRole: RoleConstants.WorkspaceViewer);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeWorkspaceAsync("workspace-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Forbidden, result.Status);
    }

    [Fact]
    public async Task AnalyzeWorkspaceAsync_returns_not_found_for_unknown_workspace()
    {
        await using var context = CreateContext();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeWorkspaceAsync("missing", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task AnalyzeCardAsync_returns_success_for_authorized_user()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeCardAsync("card-active", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.NotNull(result.Analysis);
        Assert.Equal("card", result.Analysis.ScopeType);
        Assert.Equal("card-active", result.Analysis.ScopeUId);
    }

    [Fact]
    public async Task AnalyzeCardAsync_returns_forbidden_for_unauthorized_user()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardViewer);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeCardAsync("card-active", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Forbidden, result.Status);
    }

    [Fact]
    public async Task AnalyzeCardAsync_returns_not_found_for_unknown_card()
    {
        await using var context = CreateContext();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.AnalyzeCardAsync("missing", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task SaveLatestReportAsync_returns_forbidden_if_unauthorized()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardViewer);
        var service = CreateService(context, new FakeGeminiClient(ValidGeminiJson("test")));

        var result = await service.SaveLatestReportAsync("board", "board-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Forbidden, result.Status);
    }

    [Fact]
    public async Task SaveLatestReportAsync_returns_not_found_if_no_cache()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient(ValidGeminiJson("test")));

        var result = await service.SaveLatestReportAsync("board", "board-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task GetReportHistoryAsync_returns_forbidden_if_unauthorized()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardViewer);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportHistoryAsync("board", "board-1", "requester", 1, 10, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Forbidden, result.Status);
    }

    [Fact]
    public async Task GetReportHistoryAsync_returns_empty_when_no_reports()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportHistoryAsync("board", "board-1", "requester", 1, 10, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.Empty(result.Page.Items);
    }

    [Fact]
    public async Task GetReportByIdAsync_returns_not_found_if_missing()
    {
        await using var context = CreateContext();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportByIdAsync("missing", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task GetReportByIdAsync_returns_not_found_when_json_is_invalid()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var row = SavedReport("report-1");
        row.ReportData = "invalid-json";
        context.AnalysisReports.Add(row);
        context.SaveChanges();
        var service = CreateService(context, new FakeGeminiClient("{}"));

        var result = await service.GetReportByIdAsync("report-1", "requester", CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task AnalyzeBoardAsync_handles_gemini_exception()
    {
        await using var context = CreateContext();
        SeedBoardWithCards(context, requesterRole: RoleConstants.BoardAdmin);
        var service = CreateService(context, new ExceptionGeminiClient());

        var result = await service.AnalyzeBoardAsync("board-1", "requester", false, CancellationToken.None);

        Assert.Equal(AnalysisResultStatus.Success, result.Status);
        Assert.False(result.Analysis.IsGeminiSuccess);
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

    private static void SeedWorkspaceWithCards(TodoDbContext context, string requesterRole)
    {
        context.Users.AddRange(
            new User { UserUId = "owner", UserName = "owner", Email = "owner@example.com", PasswordHash = "hash", StatusAccount = "Active" },
            new User { UserUId = "requester", UserName = "requester", Email = "requester@example.com", PasswordHash = "hash", StatusAccount = "Active" });
        context.Workspaces.Add(new Workspace { WorkspaceUId = "workspace-1", Name = "Workspace", Description = "Test" });
        context.WorkspaceMembers.Add(new WorkspaceMembers
        {
            WorkspaceMemberUId = "wm-requester",
            WorkspaceUId = "workspace-1",
            UserUId = "requester",
            Role = requesterRole
        });
        context.SaveChanges();
    }

    private static AnalysisReport SavedReport(
        string reportUId,
        DateTime? generatedAt = null,
        int progress = 64,
        bool cached = false)
    {
        var report = new ProjectAnalysisDto
        {
            ScopeType = "board",
            ScopeUId = "board-1",
            Title = "Sprint Board",
            OverallProgress = progress,
            Summary = "Saved report",
            GeneratedAt = generatedAt ?? DateTime.UtcNow,
            Model = "gemini-test",
            Cached = cached
        };

        return new AnalysisReport
        {
            ReportUId = reportUId,
            ScopeType = report.ScopeType,
            ScopeUId = report.ScopeUId,
            GeneratedByUId = "requester",
            GeneratedAt = report.GeneratedAt,
            Title = report.Title,
            OverallProgress = report.OverallProgress,
            ModelUsed = report.Model,
            ReportData = System.Text.Json.JsonSerializer.Serialize(report)
        };
    }

    private static string ValidGeminiJson(string summary)
    {
        return $$"""
        {
          "summary": "{{summary}}",
          "risks": [],
          "suggestions": [],
          "inferredMilestones": []
        }
        """;
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

    private sealed class ExceptionGeminiClient : IGeminiClient
    {
        public Task<string> GenerateJsonAsync(string prompt, object responseSchema, CancellationToken cancellationToken)
        {
            throw new Exception("Simulated Gemini error");
        }
    }
}
