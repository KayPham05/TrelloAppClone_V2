namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisSuggestionDto
    {
        public string Priority { get; set; } = "low";
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}
