using System.Security.Cryptography;
using System.Text;
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
        private const string TodoStatusKey = "todo";
        private const string InProgressStatusKey = "inProgress";
        private const string CompletedStatusKey = "completed";
        private const string OtherStatusKey = "other";
        private readonly TodoDbContext _context;
        private readonly IAuthorizationService _authorizationService;
        private readonly IGeminiClient _geminiClient;
        private readonly IMemoryCache _cache;
        private readonly GeminiSettings _settings;
        private readonly ILogger<GeminiAnalysisService> _logger;
        private readonly ProjectAnalysisPromptBuilder _promptBuilder = new();
        private static readonly JsonSerializerOptions ReportJsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };

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

        public async Task<AnalysisResult> AnalyzeWorkspaceAsync(string workspaceUId, string userUId, bool forceRefresh, CancellationToken cancellationToken)
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
                .Where(c => c.List != null && boardIds.Contains(c.List.BoardUId) && c.Status != "Deleted" && !c.IsArchived)
                .OrderBy(c => c.List!.Position)
                .ThenBy(c => c.Position)
                .ToListAsync(cancellationToken);

            var snapshot = BuildSnapshot("workspace", workspace.WorkspaceUId, workspace.Name, lists, cards);
            return await AnalyzeSnapshotAsync(snapshot, userUId, forceRefresh, cancellationToken);
        }

        public async Task<AnalysisResult> AnalyzeBoardAsync(string boardUId, string userUId, bool forceRefresh, CancellationToken cancellationToken)
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
                .Where(l => l.BoardUId == boardUId && l.Status != "Deleted" && l.Status != "Archived" && l.Status != "archived")
                .OrderBy(l => l.Position)
                .ToListAsync(cancellationToken);
            var cards = await _context.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.CardLabels)
                .Where(c => c.List != null && c.List.BoardUId == boardUId && c.Status != "Deleted" && !c.IsArchived && c.List.Status != "Deleted" && c.List.Status != "Archived" && c.List.Status != "archived")
                .OrderBy(c => c.List!.Position)
                .ThenBy(c => c.Position)
                .ToListAsync(cancellationToken);

            var snapshot = BuildSnapshot("board", board.BoardUId, board.BoardName ?? board.BoardUId, lists, cards);
            return await AnalyzeSnapshotAsync(snapshot, userUId, forceRefresh, cancellationToken);
        }

        public async Task<AnalysisResult> AnalyzeCardAsync(string cardUId, string userUId, bool forceRefresh, CancellationToken cancellationToken)
        {
            var card = await _context.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.CardLabels)
                .FirstOrDefaultAsync(c => c.CardUId == cardUId && c.Status != "Deleted" && !c.IsArchived, cancellationToken);
            if (card == null)
                return AnalysisResult.NotFound("Không tìm thấy card.");

            if (!await _authorizationService.CanViewCardAnalysisAsync(cardUId, userUId))
                return AnalysisResult.Forbidden("Bạn không có quyền phân tích card này.");

            var lists = card.List == null ? [] : new List<ModelList> { card.List };
            var snapshot = BuildSnapshot("card", card.CardUId, card.Title ?? card.CardUId, lists, [card]);
            return await AnalyzeSnapshotAsync(snapshot, userUId, forceRefresh, cancellationToken);
        }

        private async Task<AnalysisResult> AnalyzeSnapshotAsync(
            ProjectAnalysisSnapshotDto snapshot,
            string userUId,
            bool forceRefresh,
            CancellationToken cancellationToken)
        {
            var cacheKey = BuildCacheKey(snapshot.ScopeType, snapshot.ScopeUId, userUId);
            var snapshotHash = ComputeSnapshotHash(snapshot);
            var report = CreateBaseReport(snapshot);

            if (!forceRefresh &&
                _cache.TryGetValue<AnalysisCacheEntry>(cacheKey, out var cached) &&
                cached != null &&
                cached.SnapshotHash == snapshotHash)
            {
                // Lấy phần AI text từ cache ghép vào số liệu mới
                report.Summary = cached.Report.Summary;
                report.Risks = cached.Report.Risks;
                report.Suggestions = cached.Report.Suggestions;
                report.InferredMilestones = cached.Report.InferredMilestones;
                report.Cached = true;
                report.IsGeminiSuccess = cached.CanSave;
                
                return AnalysisResult.Success(report);
            }
            var geminiSucceeded = false;
            try
            {
                var prompt = _promptBuilder.BuildPrompt(snapshot, report.Metrics, report.OverallProgress);
                var json = await _geminiClient.GenerateJsonAsync(prompt, _promptBuilder.BuildResponseSchema(), cancellationToken);
                MergeGeminiJson(report, snapshot, json);
                geminiSucceeded = true;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Gemini analysis fallback used for {ScopeType} {ScopeUId}", snapshot.ScopeType, snapshot.ScopeUId);
            }

            _cache.Set(
                cacheKey,
                new AnalysisCacheEntry(report, snapshotHash, geminiSucceeded),
                TimeSpan.FromMinutes(Math.Max(1, _settings.CacheMinutes)));
            report.IsGeminiSuccess = geminiSucceeded;
            return AnalysisResult.Success(report);
        }

        public async Task<AnalysisReportSaveResult> SaveLatestReportAsync(
            string scopeType,
            string scopeUId,
            string userUId,
            CancellationToken cancellationToken)
        {
            scopeType = scopeType.ToLowerInvariant();
            if (!await CanViewAnalysisScopeAsync(scopeType, scopeUId, userUId))
                return AnalysisReportSaveResult.Forbidden("Bạn không có quyền lưu báo cáo này.");

            var cacheKey = BuildCacheKey(scopeType, scopeUId, userUId);
            if (!_cache.TryGetValue<AnalysisCacheEntry>(cacheKey, out var cached) || cached == null)
                return AnalysisReportSaveResult.NotFound("Không tìm thấy báo cáo hiện tại để lưu.");

            if (!cached.CanSave)
                return AnalysisReportSaveResult.BadRequest("Chỉ có thể lưu báo cáo Gemini thành công.");

            var summary = await SaveReportHistoryAsync(cached.Report, userUId, cancellationToken);
            return AnalysisReportSaveResult.Success(summary);
        }

        public async Task<AnalysisReportHistoryResult> GetReportHistoryAsync(
            string scopeType,
            string scopeUId,
            string userUId,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            if (!await CanViewAnalysisScopeAsync(scopeType, scopeUId, userUId))
                return AnalysisReportHistoryResult.Forbidden("Bạn không có quyền xem lịch sử báo cáo này.");

            page = Math.Max(1, page);
            pageSize = Math.Clamp(pageSize, 1, 20);

            var rows = await _context.AnalysisReports
                .AsNoTracking()
                .Where(r => r.ScopeType == scopeType && r.ScopeUId == scopeUId)
                .OrderByDescending(r => r.GeneratedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize + 1)
                .Select(r => new AnalysisReportSummaryDto
                {
                    ReportUId = r.ReportUId,
                    ScopeType = r.ScopeType,
                    ScopeUId = r.ScopeUId,
                    Title = r.Title,
                    OverallProgress = r.OverallProgress,
                    ModelUsed = r.ModelUsed,
                    GeneratedAt = r.GeneratedAt
                })
                .ToListAsync(cancellationToken);

            return AnalysisReportHistoryResult.Success(new AnalysisReportHistoryPageDto
            {
                Items = rows.Take(pageSize).ToList(),
                Page = page,
                PageSize = pageSize,
                HasMore = rows.Count > pageSize
            });
        }

        public async Task<AnalysisResult> GetReportByIdAsync(string reportUId, string userUId, CancellationToken cancellationToken)
        {
            var row = await _context.AnalysisReports
                .AsNoTracking()
                .FirstOrDefaultAsync(r => r.ReportUId == reportUId, cancellationToken);
            if (row == null)
                return AnalysisResult.NotFound("Không tìm thấy báo cáo.");

            if (!await CanViewAnalysisScopeAsync(row.ScopeType, row.ScopeUId, userUId))
                return AnalysisResult.Forbidden("Bạn không có quyền xem báo cáo này.");

            var report = JsonSerializer.Deserialize<ProjectAnalysisDto>(row.ReportData, ReportJsonOptions);
            if (report == null)
                return AnalysisResult.NotFound("Không đọc được dữ liệu báo cáo.");

            report.Cached = false;
            return AnalysisResult.Success(report);
        }

        private async Task<AnalysisReportSummaryDto> SaveReportHistoryAsync(
            ProjectAnalysisDto report,
            string userUId,
            CancellationToken cancellationToken)
        {
            report.Cached = false;

            var entity = new AnalysisReport
            {
                ScopeType = report.ScopeType,
                ScopeUId = report.ScopeUId,
                GeneratedByUId = userUId,
                GeneratedAt = report.GeneratedAt,
                Title = Truncate(report.Title, 200),
                OverallProgress = Math.Clamp(report.OverallProgress, 0, 100),
                ModelUsed = Truncate(report.Model, 100),
                ReportData = JsonSerializer.Serialize(report, ReportJsonOptions)
            };

            _context.AnalysisReports.Add(entity);
            await _context.SaveChangesAsync(cancellationToken);
            await CleanupReportHistoryAsync(report.ScopeType, report.ScopeUId, cancellationToken);

            return new AnalysisReportSummaryDto
            {
                ReportUId = entity.ReportUId,
                ScopeType = entity.ScopeType,
                ScopeUId = entity.ScopeUId,
                Title = entity.Title,
                OverallProgress = entity.OverallProgress,
                ModelUsed = entity.ModelUsed,
                GeneratedAt = entity.GeneratedAt
            };
        }

        private async Task CleanupReportHistoryAsync(
            string scopeType,
            string scopeUId,
            CancellationToken cancellationToken)
        {
            if (_context.Database.IsRelational())
            {
                await _context.AnalysisReports
                    .Where(r => r.ScopeType == scopeType && r.ScopeUId == scopeUId)
                    .OrderByDescending(r => r.GeneratedAt)
                    .Skip(5)
                    .ExecuteDeleteAsync(cancellationToken);
                return;
            }

            var oldReports = await _context.AnalysisReports
                .Where(r => r.ScopeType == scopeType && r.ScopeUId == scopeUId)
                .OrderByDescending(r => r.GeneratedAt)
                .Skip(5)
                .ToListAsync(cancellationToken);
            if (oldReports.Count > 0)
            {
                _context.AnalysisReports.RemoveRange(oldReports);
                await _context.SaveChangesAsync(cancellationToken);
            }
        }

        private async Task<bool> CanViewAnalysisScopeAsync(
            string scopeType,
            string scopeUId,
            string userUId)
        {
            return scopeType switch
            {
                "workspace" => await _authorizationService.CanViewWorkspaceAnalysisAsync(scopeUId, userUId),
                "board" => await _authorizationService.CanViewBoardAnalysisAsync(scopeUId, userUId),
                "card" => await _authorizationService.CanViewCardAnalysisAsync(scopeUId, userUId),
                _ => false
            };
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
                Summary = BuildMetricSummary(snapshot, metrics),
                Risks = BuildDeterministicRisks(snapshot, metrics),
                Suggestions = BuildDeterministicSuggestions(metrics),
                Breakdown = BuildBreakdown(snapshot),
                GeneratedAt = DateTime.UtcNow.AddHours(7),
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
            var today = DateTime.UtcNow.AddHours(7).Date;
            var dueSoonLimit = today.AddDays(3);
            var statusDistribution = snapshot.Cards
                .GroupBy(GetStatusCategory)
                .ToDictionary(g => g.Key, g => g.Count());

            return new ProjectAnalysisMetricDto
            {
                TotalCards = snapshot.Cards.Count,
                TodoCards = statusDistribution.GetValueOrDefault(TodoStatusKey),
                InProgressCards = statusDistribution.GetValueOrDefault(InProgressStatusKey),
                CompletedCards = completedCards,
                OtherCards = statusDistribution.GetValueOrDefault(OtherStatusKey),
                OverdueCards = snapshot.Cards.Count(c => c.DueDate.HasValue && c.DueDate.Value.Date < today && !IsCompletedCard(c)),
                DueSoonCards = snapshot.Cards.Count(c =>
                    c.DueDate.HasValue &&
                    c.DueDate.Value.Date >= today &&
                    c.DueDate.Value.Date <= dueSoonLimit &&
                    !IsCompletedCard(c)),
                TotalTodoItems = snapshot.Cards.Sum(c => c.TotalTodoItems),
                CompletedTodoItems = snapshot.Cards.Sum(c => c.CompletedTodoItems),
                StatusDistribution = new Dictionary<string, int>
                {
                    [TodoStatusKey] = statusDistribution.GetValueOrDefault(TodoStatusKey),
                    [InProgressStatusKey] = statusDistribution.GetValueOrDefault(InProgressStatusKey),
                    [CompletedStatusKey] = statusDistribution.GetValueOrDefault(CompletedStatusKey),
                    [OtherStatusKey] = statusDistribution.GetValueOrDefault(OtherStatusKey)
                }
            };
        }

        private static int CalculateProgress(ProjectAnalysisMetricDto metrics)
        {
            if (metrics.TotalCards == 0)
                return 0;

            return Math.Clamp((int)Math.Round((double)metrics.CompletedCards / metrics.TotalCards * 100), 0, 100);
        }

        private static List<ProjectAnalysisBreakdownDto> BuildBreakdown(ProjectAnalysisSnapshotDto snapshot)
        {
            var today = DateTime.UtcNow.AddHours(7).Date;
            return snapshot.Lists.Select(list =>
            {
                var cards = snapshot.Cards.Where(c => c.ListUId == list.ListUId).ToList();
                return new ProjectAnalysisBreakdownDto
                {
                    Name = list.Name,
                    TotalCards = cards.Count,
                    CompletedCards = cards.Count(IsCompletedCard),
                    OverdueCards = cards.Count(c => c.DueDate.HasValue && c.DueDate.Value.Date < today && !IsCompletedCard(c))
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
            if (!string.IsNullOrWhiteSpace(content.Summary))
                report.Summary = Truncate(content.Summary, 800);

            var geminiRisks = content.Risks
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
            if (geminiRisks.Count > 0)
                report.Risks = geminiRisks;

            var geminiSuggestions = content.Suggestions
                .Take(Math.Max(0, _settings.MaxSuggestions))
                .Select(s => new ProjectAnalysisSuggestionDto
                {
                    Priority = NormalizeLevel(s.Priority),
                    Title = Truncate(s.Title, 120),
                    Description = Truncate(s.Description, 200)
                })
                .Where(s => !string.IsNullOrWhiteSpace(s.Title))
                .ToList();
            if (geminiSuggestions.Count > 0)
                report.Suggestions = geminiSuggestions;

            var geminiMilestones = content.InferredMilestones
                .Take(5)
                .Select(m => new ProjectAnalysisMilestoneDto
                {
                    Name = Truncate(m.Name, 120),
                    Status = NormalizeMilestoneStatus(m.Status),
                    Description = Truncate(m.Description, 200)
                })
                .Where(m => !string.IsNullOrWhiteSpace(m.Name))
                .ToList();
            if (geminiMilestones.Count > 0)
                report.InferredMilestones = geminiMilestones;
        }

        private static string BuildMetricSummary(ProjectAnalysisSnapshotDto snapshot, ProjectAnalysisMetricDto metrics)
        {
            if (metrics.TotalCards == 0)
                return "Bảng chưa có thẻ để phân tích. Hãy thêm một vài thẻ, trạng thái và hạn xử lý để báo cáo có ngữ cảnh hơn.";

            var signals = new List<string>();

            if (metrics.OverdueCards > 0)
                signals.Add($"Có {metrics.OverdueCards} thẻ quá hạn cần xử lý ưu tiên");
            if (metrics.DueSoonCards > 0)
                signals.Add($"{metrics.DueSoonCards} thẻ sắp đến hạn trong 3 ngày tới");
            if (metrics.TotalCards < 3)
                signals.Add("Dữ liệu còn ít nên nhận định chỉ mang tính định hướng");
            if (snapshot.Cards.Count > 0 && metrics.TotalTodoItems == 0)
                signals.Add("Chưa có checklist để đo mức hoàn thành chi tiết");

            return signals.Count == 0 ? "Dự án đang diễn ra bình thường." : $"{string.Join(". ", signals)}.";
        }

        private static List<ProjectAnalysisRiskDto> BuildDeterministicRisks(ProjectAnalysisSnapshotDto snapshot, ProjectAnalysisMetricDto metrics)
        {
            var risks = new List<ProjectAnalysisRiskDto>();
            var today = DateTime.UtcNow.AddHours(7).Date;
            var dueSoonLimit = today.AddDays(3);

            var overdueCardIds = snapshot.Cards
                .Where(c => c.DueDate.HasValue && c.DueDate.Value.Date < today && !IsCompletedCard(c))
                .Select(c => c.CardUId)
                .Take(5)
                .ToList();
            if (overdueCardIds.Count > 0)
            {
                risks.Add(new ProjectAnalysisRiskDto
                {
                    Severity = "high",
                    Title = "Thẻ quá hạn",
                    Description = $"{metrics.OverdueCards} thẻ chưa hoàn tất đã quá hạn, có thể làm chậm tiến độ bảng.",
                    RelatedCardUIds = overdueCardIds
                });
            }

            var dueSoonCardIds = snapshot.Cards
                .Where(c => c.DueDate.HasValue && c.DueDate.Value.Date >= today && c.DueDate.Value.Date <= dueSoonLimit && !IsCompletedCard(c))
                .Select(c => c.CardUId)
                .Take(5)
                .ToList();
            if (dueSoonCardIds.Count > 0)
            {
                risks.Add(new ProjectAnalysisRiskDto
                {
                    Severity = "medium",
                    Title = "Sắp đến hạn",
                    Description = $"{metrics.DueSoonCards} thẻ sẽ đến hạn trong 3 ngày tới.",
                    RelatedCardUIds = dueSoonCardIds
                });
            }

            if (metrics.TotalCards >= 3 && CalculateProgress(metrics) < 25)
            {
                risks.Add(new ProjectAnalysisRiskDto
                {
                    Severity = "medium",
                    Title = "Tiến độ thấp",
                    Description = "Tỷ lệ thẻ hoàn tất còn thấp so với tổng số thẻ hiện có."
                });
            }

            return risks;
        }

        private static List<ProjectAnalysisSuggestionDto> BuildDeterministicSuggestions(ProjectAnalysisMetricDto metrics)
        {
            var suggestions = new List<ProjectAnalysisSuggestionDto>();

            if (metrics.OverdueCards > 0)
            {
                suggestions.Add(new ProjectAnalysisSuggestionDto
                {
                    Priority = "high",
                    Title = "Ưu tiên thẻ quá hạn",
                    Description = "Rà soát và xử lý các thẻ quá hạn trước khi thêm công việc mới."
                });
            }

            if (metrics.DueSoonCards > 0)
            {
                suggestions.Add(new ProjectAnalysisSuggestionDto
                {
                    Priority = "medium",
                    Title = "Chốt kế hoạch thẻ sắp đến hạn",
                    Description = "Cập nhật owner, checklist hoặc trạng thái cho các thẻ sắp đến hạn."
                });
            }

            if (metrics.TotalCards > 0 && metrics.CompletedCards == 0)
            {
                suggestions.Add(new ProjectAnalysisSuggestionDto
                {
                    Priority = "medium",
                    Title = "Tạo một mốc hoàn tất nhỏ",
                    Description = "Chọn 1-2 thẻ có phạm vi nhỏ để hoàn tất sớm và tạo tín hiệu tiến độ."
                });
            }

            if (metrics.TotalCards > 0 && metrics.TotalTodoItems == 0)
            {
                suggestions.Add(new ProjectAnalysisSuggestionDto
                {
                    Priority = "low",
                    Title = "Bổ sung checklist",
                    Description = "Thêm checklist cho các thẻ quan trọng để theo dõi tiến độ chi tiết hơn."
                });
            }

            if (suggestions.Count == 0)
            {
                suggestions.Add(new ProjectAnalysisSuggestionDto
                {
                    Priority = "low",
                    Title = "Duy trì cập nhật trạng thái",
                    Description = "Tiếp tục cập nhật trạng thái thẻ sau mỗi thay đổi để báo cáo phản ánh dữ liệu mới nhất."
                });
            }

            return suggestions.Take(5).ToList();
        }

        private static bool IsCompletedCard(ProjectAnalysisSnapshotCardDto card)
        {
            var status = card.Status ?? string.Empty;
            return ContainsAny(status, "completed", "done", "hoan_thanh", "xong");
        }

        private static string GetStatusCategory(ProjectAnalysisSnapshotCardDto card)
        {
            var status = card.Status ?? string.Empty;
            if (IsCompletedCard(card))
                return CompletedStatusKey;
            if (ContainsAny(status, "to do", "todo", "chua lam", "new", "open"))
                return TodoStatusKey;
            if (ContainsAny(status, "in progress", "doing", "dang lam", "active"))
                return InProgressStatusKey;
            return OtherStatusKey;
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

        private string BuildCacheKey(string scopeType, string scopeUId, string userUId)
        {
            return $"analysis:{scopeType}:{scopeUId}:{userUId}:{_settings.Model}";
        }

        private static string ComputeSnapshotHash(ProjectAnalysisSnapshotDto snapshot)
        {
            var json = JsonSerializer.Serialize(snapshot, ReportJsonOptions);
            return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(json)));
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

        private sealed record AnalysisCacheEntry(
            ProjectAnalysisDto Report,
            string SnapshotHash,
            bool CanSave);
    }
}
