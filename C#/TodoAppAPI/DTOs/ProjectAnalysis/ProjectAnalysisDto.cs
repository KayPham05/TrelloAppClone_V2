namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisDto
    {
        public string ScopeType { get; set; } = string.Empty;
        public string ScopeUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public int OverallProgress { get; set; }
        public string Summary { get; set; } = string.Empty;
        public List<ProjectAnalysisRiskDto> Risks { get; set; } = [];
        public List<ProjectAnalysisSuggestionDto> Suggestions { get; set; } = [];
        public ProjectAnalysisMetricDto Metrics { get; set; } = new();
        public List<ProjectAnalysisBreakdownDto> Breakdown { get; set; } = [];
        public List<ProjectAnalysisMilestoneDto> InferredMilestones { get; set; } = [];
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
        public string Model { get; set; } = string.Empty;
        public bool Cached { get; set; }
    }
}
