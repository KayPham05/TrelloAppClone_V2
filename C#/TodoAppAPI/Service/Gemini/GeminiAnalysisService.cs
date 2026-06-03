using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs.ProjectAnalysis;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using ModelList = TodoAppAPI.Models.List;

namespace TodoAppAPI.Service.Gemini
{
    public class GeminiAnalysisService : IGeminiAnalysisService
    {
        private const string AiUnavailableSummary = "AI summary is temporarily unavailable. Showing metric data only.";
        private readonly TodoDbContext _context;
        private readonly IAuthorizationService _authorizationService;
        private readonly IGeminiClient _geminiClient;
        private readonly IMemoryCache _cache;
        private readonly GeminiSettings _settings;
        private readonly ILogger<GeminiAnalysisService> _logger;
        private readonly ProjectAnalysisPromptBuilder _promptBuilder = new();

        public GeminiAnalysisService(
            TodoDbContext context,
            IAuthorizationService authorizationService,
            IGeminiClient geminiClient,
            IMemoryCache cache,
            IOptions<GeminiSettings> settings,
            ILogger<GeminiAnalysisService> logger)
        {
            _context = context;
            _authorizationService = authorizationService;
            _geminiClient = geminiClient;
            _cache = cache;
            _settings = settings.Value;
            _logger = logger;
        }

        public async Task<AnalysisResult> AnalyzeWorkspaceAsync(string workspaceUId, string userUId, CancellationToken cancellationToken)
        {
            var workspace = await _context.Workspaces
                .AsNoTracking()
                .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceUId && w.Status != "Deleted", cancellationToken);
            if (workspace == null)
                return AnalysisResult.NotFound("Không tìm thấy workspace.");

            if (!await _authorizationService.CanViewWorkspaceAnalysisAsync(workspaceUId, userUId))
                return AnalysisResult.Forbidden("Bạn không có quyền phân tích workspace này.");

            var boardIds = await _context.Boards
                .AsNoTracking()
                .Where(b => b.WorkspaceUId == workspaceUId)
                .Select(b => b.BoardUId)
                .ToListAsync(cancellationToken);
            var lists = await _context.Lists
                .AsNoTracking()
                .Where(l => boardIds.Contains(l.BoardUId))
                .OrderBy(l => l.Position)
                .ToListAsync(cancellationToken);
            var cards = await _context.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.CardLabels)
                .Where(c => c.List != null && boardIds.Contains(c.List.BoardUId) && c.Status != "Deleted")
                .OrderBy(c => c.List!.Position)
                .ThenBy(c => c.Position)
                .ToListAsync(cancellationToken);

            var snapshot = BuildSnapshot("workspace", workspace.WorkspaceUId, workspace.Name, lists, cards);
            return await AnalyzeSnapshotAsync(snapshot, userUId, cancellationToken);
        }

        public async Task<AnalysisResult> AnalyzeBoardAsync(string boardUId, string userUId, CancellationToken cancellationToken)
        {
            var board = await _context.Boards
                .AsNoTracking()
                .FirstOrDefaultAsync(b => b.BoardUId == boardUId, cancellationToken);
            if (board == null)
                return AnalysisResult.NotFound("Không tìm thấy board.");

            if (!await _authorizationService.CanViewBoardAnalysisAsync(boardUId, userUId))
                return AnalysisResult.Forbidden("Bạn không có quyền phân tích board này.");

            var lists = await _context.Lists
                .AsNoTracking()
                .Where(l => l.BoardUId == boardUId)
                .OrderBy(l => l.Position)
                .ToListAsync(cancellationToken);
            var cards = await _context.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.CardLabels)
                .Where(c => c.List != null && c.List.BoardUId == boardUId && c.Status != "Deleted")
                .OrderBy(c => c.List!.Position)
                .ThenBy(c => c.Position)
                .ToListAsync(cancellationToken);

            var snapshot = BuildSnapshot("board", board.BoardUId, board.BoardName ?? board.BoardUId, lists, cards);
            return await AnalyzeSnapshotAsync(snapshot, userUId, cancellationToken);
        }

        public async Task<AnalysisResult> AnalyzeCardAsync(string cardUId, string userUId, CancellationToken cancellationToken)
        {
            var card = await _context.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.CardLabels)
                .FirstOrDefaultAsync(c => c.CardUId == cardUId && c.Status != "Deleted", cancellationToken);
            if (card == null)
                return AnalysisResult.NotFound("Không tìm thấy card.");

            if (!await _authorizationService.CanViewCardAnalysisAsync(cardUId, userUId))
                return AnalysisResult.Forbidden("Bạn không có quyền phân tích card này.");

            var lists = card.List == null ? [] : new List<ModelList> { card.List };
            var snapshot = BuildSnapshot("card", card.CardUId, card.Title ?? card.CardUId, lists, [card]);
            return await AnalyzeSnapshotAsync(snapshot, userUId, cancellationToken);
        }

        private async Task<AnalysisResult> AnalyzeSnapshotAsync(
            ProjectAnalysisSnapshotDto snapshot,
            string userUId,
            CancellationToken cancellationToken)
        {
            var cacheKey = $"analysis:{snapshot.ScopeType}:{snapshot.ScopeUId}:{userUId}:{_settings.Model}";
            if (_cache.TryGetValue<ProjectAnalysisDto>(cacheKey, out var cached) && cached != null)
            {
                cached.Cached = true;
                return AnalysisResult.Success(cached);
            }

            var report = CreateBaseReport(snapshot);
            try
            {
                var prompt = _promptBuilder.BuildPrompt(snapshot, report.Metrics, report.OverallProgress);
                var json = await _geminiClient.GenerateJsonAsync(prompt, _promptBuilder.BuildResponseSchema(), cancellationToken);
                MergeGeminiJson(report, snapshot, json);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Gemini analysis fallback used for {ScopeType} {ScopeUId}", snapshot.ScopeType, snapshot.ScopeUId);
                ApplyFallback(report);
            }

            _cache.Set(cacheKey, report, TimeSpan.FromMinutes(Math.Max(1, _settings.CacheMinutes)));
            return AnalysisResult.Success(report);
        }

        private ProjectAnalysisDto CreateBaseReport(ProjectAnalysisSnapshotDto snapshot)
        {
            var metrics = BuildMetrics(snapshot);
            return new ProjectAnalysisDto
            {
                ScopeType = snapshot.ScopeType,
                ScopeUId = snapshot.ScopeUId,
                Title = snapshot.Title,
                Metrics = metrics,
                OverallProgress = CalculateProgress(metrics),
                Summary = AiUnavailableSummary,
                Breakdown = BuildBreakdown(snapshot),
                GeneratedAt = DateTime.UtcNow,
                Model = string.IsNullOrWhiteSpace(_settings.Model) ? "gemini-3.5-flash" : _settings.Model,
                Cached = false
            };
        }

        private static ProjectAnalysisSnapshotDto BuildSnapshot(
            string scopeType,
            string scopeUId,
            string title,
            IReadOnlyCollection<ModelList> lists,
            IReadOnlyCollection<Card> cards)
        {
            return new ProjectAnalysisSnapshotDto
            {
                ScopeType = scopeType,
                ScopeUId = scopeUId,
                Title = title,
                Lists = lists.Select(l => new ProjectAnalysisSnapshotListDto
                {
                    ListUId = l.ListUId,
                    Name = l.ListName,
                    Position = l.Position
                }).ToList(),
                Cards = cards.Select(c => new ProjectAnalysisSnapshotCardDto
                {
                    CardUId = c.CardUId,
                    Title = c.Title ?? c.CardUId,
                    ListUId = c.ListUId,
                    ListName = c.List?.ListName ?? string.Empty,
                    Status = c.Status,
                    DueDate = c.DueDate,
                    Position = c.Position,
                    TotalTodoItems = c.TodoItems?.Count ?? 0,
                    CompletedTodoItems = c.TodoItems?.Count(t => t.IsCompleted) ?? 0,
                    LabelNames = c.CardLabels?.Select(l => l.Title).Where(t => !string.IsNullOrWhiteSpace(t)).ToList() ?? []
                }).ToList()
            };
        }

        private static ProjectAnalysisMetricDto BuildMetrics(ProjectAnalysisSnapshotDto snapshot)
        {
            var completedCards = snapshot.Cards.Count(IsCompletedCard);
            return new ProjectAnalysisMetricDto
            {
                TotalCards = snapshot.Cards.Count,
                CompletedCards = completedCards,
                OverdueCards = snapshot.Cards.Count(c => c.DueDate.HasValue && c.DueDate.Value.Date < DateTime.UtcNow.Date && !IsCompletedCard(c)),
                TotalTodoItems = snapshot.Cards.Sum(c => c.TotalTodoItems),
                CompletedTodoItems = snapshot.Cards.Sum(c => c.CompletedTodoItems)
            };
        }

        private static int CalculateProgress(ProjectAnalysisMetricDto metrics)
        {
            var ratios = new List<double>();
            if (metrics.TotalTodoItems > 0)
                ratios.Add((double)metrics.CompletedTodoItems / metrics.TotalTodoItems);
            if (metrics.TotalCards > 0)
                ratios.Add((double)metrics.CompletedCards / metrics.TotalCards);
            if (ratios.Count == 0)
                return 0;
            return Math.Clamp((int)Math.Round(ratios.Average() * 100), 0, 100);
        }

        private static List<ProjectAnalysisBreakdownDto> BuildBreakdown(ProjectAnalysisSnapshotDto snapshot)
        {
            return snapshot.Lists.Select(list =>
            {
                var cards = snapshot.Cards.Where(c => c.ListUId == list.ListUId).ToList();
                return new ProjectAnalysisBreakdownDto
                {
                    Name = list.Name,
                    TotalCards = cards.Count,
                    CompletedCards = cards.Count(IsCompletedCard),
                    OverdueCards = cards.Count(c => c.DueDate.HasValue && c.DueDate.Value.Date < DateTime.UtcNow.Date && !IsCompletedCard(c))
                };
            }).ToList();
        }

        private void MergeGeminiJson(ProjectAnalysisDto report, ProjectAnalysisSnapshotDto snapshot, string json)
        {
            var content = JsonSerializer.Deserialize<GeminiContentDto>(json, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
            if (content == null)
                throw new JsonException("Gemini JSON did not match expected shape.");

            var validCardIds = snapshot.Cards.Select(c => c.CardUId).ToHashSet(StringComparer.OrdinalIgnoreCase);
            report.Summary = Truncate(string.IsNullOrWhiteSpace(content.Summary) ? AiUnavailableSummary : content.Summary, 800);
            report.Risks = content.Risks
                .Take(Math.Max(0, _settings.MaxRisks))
                .Select(r => new ProjectAnalysisRiskDto
                {
                    Severity = NormalizeLevel(r.Severity),
                    Title = Truncate(r.Title, 120),
                    Description = Truncate(r.Description, 200),
                    RelatedCardUIds = r.RelatedCardUIds
                        .Where(validCardIds.Contains)
                        .Distinct(StringComparer.OrdinalIgnoreCase)
                        .ToList()
                })
                .Where(r => !string.IsNullOrWhiteSpace(r.Title))
                .ToList();
            report.Suggestions = content.Suggestions
                .Take(Math.Max(0, _settings.MaxSuggestions))
                .Select(s => new ProjectAnalysisSuggestionDto
                {
                    Priority = NormalizeLevel(s.Priority),
                    Title = Truncate(s.Title, 120),
                    Description = Truncate(s.Description, 200)
                })
                .Where(s => !string.IsNullOrWhiteSpace(s.Title))
                .ToList();
            report.InferredMilestones = content.InferredMilestones
                .Take(5)
                .Select(m => new ProjectAnalysisMilestoneDto
                {
                    Name = Truncate(m.Name, 120),
                    Status = NormalizeMilestoneStatus(m.Status),
                    Description = Truncate(m.Description, 200)
                })
                .Where(m => !string.IsNullOrWhiteSpace(m.Name))
                .ToList();
        }

        private static void ApplyFallback(ProjectAnalysisDto report)
        {
            report.Summary = AiUnavailableSummary;
            report.Risks = [];
            report.Suggestions = [];
            report.InferredMilestones = [];
        }

        private static bool IsCompletedCard(ProjectAnalysisSnapshotCardDto card)
        {
            var status = card.Status ?? string.Empty;
            var listName = card.ListName ?? string.Empty;
            return ContainsAny(status, "completed", "done", "hoan_thanh", "hoàn thành", "xong") ||
                   ContainsAny(listName, "completed", "done", "hoan_thanh", "hoàn thành", "xong");
        }

        private static bool ContainsAny(string value, params string[] needles)
        {
            return needles.Any(n => value.Contains(n, StringComparison.OrdinalIgnoreCase));
        }

        private static string NormalizeLevel(string value)
        {
            var normalized = value.Trim().ToLowerInvariant();
            return ProjectAnalysisValues.Levels.Contains(normalized) ? normalized : "low";
        }

        private static string NormalizeMilestoneStatus(string value)
        {
            return ProjectAnalysisValues.MilestoneStatuses.Contains(value) ? value : "onTrack";
        }

        private static string Truncate(string? value, int maxLength)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;
            return value.Length <= maxLength ? value : value[..maxLength];
        }

        private sealed class GeminiContentDto
        {
            public string Summary { get; set; } = string.Empty;
            public List<GeminiRiskDto> Risks { get; set; } = [];
            public List<GeminiSuggestionDto> Suggestions { get; set; } = [];
            public List<GeminiMilestoneDto> InferredMilestones { get; set; } = [];
        }

        private sealed class GeminiRiskDto
        {
            public string Severity { get; set; } = "low";
            public string Title { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
            public List<string> RelatedCardUIds { get; set; } = [];
        }

        private sealed class GeminiSuggestionDto
        {
            public string Priority { get; set; } = "low";
            public string Title { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
        }

        private sealed class GeminiMilestoneDto
        {
            public string Name { get; set; } = string.Empty;
            public string Status { get; set; } = "onTrack";
            public string Description { get; set; } = string.Empty;
        }
    }
}
