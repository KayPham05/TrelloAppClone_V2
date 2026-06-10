namespace TodoAppAPI.Models
{
    public class AnalysisReport
    {
        public string ReportUId { get; set; } = Guid.NewGuid().ToString();
        public string ScopeType { get; set; } = string.Empty;
        public string ScopeUId { get; set; } = string.Empty;
        public string GeneratedByUId { get; set; } = string.Empty;
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
        public string Title { get; set; } = string.Empty;
        public int OverallProgress { get; set; }
        public string ModelUsed { get; set; } = string.Empty;
        public string ReportData { get; set; } = string.Empty;

        public User? GeneratedBy { get; set; }
    }
}
