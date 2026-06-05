using TodoAppAPI.DTOs.ProjectAnalysis;

namespace TodoAppAPI.Interfaces
{
    public interface IGeminiAnalysisService
    {
        Task<AnalysisResult> AnalyzeWorkspaceAsync(string workspaceUId, string userUId, bool forceRefresh, CancellationToken cancellationToken);
        Task<AnalysisResult> AnalyzeBoardAsync(string boardUId, string userUId, bool forceRefresh, CancellationToken cancellationToken);
        Task<AnalysisResult> AnalyzeCardAsync(string cardUId, string userUId, bool forceRefresh, CancellationToken cancellationToken);
        Task<AnalysisReportSaveResult> SaveLatestReportAsync(string scopeType, string scopeUId, string userUId, CancellationToken cancellationToken);
        Task<AnalysisReportHistoryResult> GetReportHistoryAsync(string scopeType, string scopeUId, string userUId, int page, int pageSize, CancellationToken cancellationToken);
        Task<AnalysisResult> GetReportByIdAsync(string reportUId, string userUId, CancellationToken cancellationToken);
    }
}
