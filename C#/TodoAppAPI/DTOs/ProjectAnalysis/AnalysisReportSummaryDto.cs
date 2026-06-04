namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class AnalysisReportSummaryDto
    {
        public string ReportUId { get; set; } = string.Empty;
        public string ScopeType { get; set; } = string.Empty;
        public string ScopeUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public int OverallProgress { get; set; }
        public string ModelUsed { get; set; } = string.Empty;
        public DateTime GeneratedAt { get; set; }
    }
}
