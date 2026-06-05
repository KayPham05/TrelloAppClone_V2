namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisRiskDto
    {
        public string Severity { get; set; } = "low";
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public List<string> RelatedCardUIds { get; set; } = [];
    }
}
