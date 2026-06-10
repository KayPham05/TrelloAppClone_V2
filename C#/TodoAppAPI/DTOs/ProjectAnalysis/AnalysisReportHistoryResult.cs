namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class AnalysisReportHistoryResult
    {
        public AnalysisResultStatus Status { get; private set; }
        public AnalysisReportHistoryPageDto? Page { get; private set; }
        public string? Message { get; private set; }

        public static AnalysisReportHistoryResult Success(AnalysisReportHistoryPageDto page) => new()
        {
            Status = AnalysisResultStatus.Success,
            Page = page
        };

        public static AnalysisReportHistoryResult NotFound(string message) => new()
        {
            Status = AnalysisResultStatus.NotFound,
            Message = message
        };

        public static AnalysisReportHistoryResult Forbidden(string message) => new()
        {
            Status = AnalysisResultStatus.Forbidden,
            Message = message
        };
    }
}
