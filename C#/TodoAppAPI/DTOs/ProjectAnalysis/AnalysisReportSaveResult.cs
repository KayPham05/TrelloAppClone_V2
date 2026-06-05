namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class AnalysisReportSaveResult
    {
        public AnalysisResultStatus Status { get; private set; }
        public AnalysisReportSummaryDto? Report { get; private set; }
        public string Message { get; private set; } = string.Empty;

        public static AnalysisReportSaveResult Success(AnalysisReportSummaryDto report) => new()
        {
            Status = AnalysisResultStatus.Success,
            Report = report
        };

        public static AnalysisReportSaveResult NotFound(string message) => new()
        {
            Status = AnalysisResultStatus.NotFound,
            Message = message
        };

        public static AnalysisReportSaveResult Forbidden(string message) => new()
        {
            Status = AnalysisResultStatus.Forbidden,
            Message = message
        };

        public static AnalysisReportSaveResult BadRequest(string message) => new()
        {
            Status = AnalysisResultStatus.BadRequest,
            Message = message
        };
    }
}
