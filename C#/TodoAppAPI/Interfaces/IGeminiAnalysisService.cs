using TodoAppAPI.DTOs.ProjectAnalysis;

namespace TodoAppAPI.Interfaces
{
    public interface IGeminiAnalysisService
    {
        Task<AnalysisResult> AnalyzeWorkspaceAsync(string workspaceUId, string userUId, bool forceRefresh, CancellationToken cancellationToken);
        Task<AnalysisResult> AnalyzeBoardAsync(string boardUId, string userUId, bool forceRefresh, CancellationToken cancellationToken);
        Task<AnalysisResult> AnalyzeCardAsync(string cardUId, string userUId, bool forceRefresh, CancellationToken cancellationToken);
    }
}
