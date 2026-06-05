namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class AnalysisReportHistoryPageDto
    {
        public List<AnalysisReportSummaryDto> Items { get; set; } = [];
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasMore { get; set; }
    }
}
