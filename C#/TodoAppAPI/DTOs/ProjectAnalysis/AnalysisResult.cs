namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public enum AnalysisResultStatus
    {
        Success,
        NotFound,
        Forbidden,
        BadRequest
    }

    public class AnalysisResult
    {
        public AnalysisResultStatus Status { get; private set; }
        public ProjectAnalysisDto? Analysis { get; private set; }
        public string? Message { get; private set; }

        public static AnalysisResult Success(ProjectAnalysisDto analysis) => new()
        {
            Status = AnalysisResultStatus.Success,
            Analysis = analysis
        };

        public static AnalysisResult NotFound(string message) => new()
        {
            Status = AnalysisResultStatus.NotFound,
            Message = message
        };

        public static AnalysisResult Forbidden(string message) => new()
        {
            Status = AnalysisResultStatus.Forbidden,
            Message = message
        };
    }
}
