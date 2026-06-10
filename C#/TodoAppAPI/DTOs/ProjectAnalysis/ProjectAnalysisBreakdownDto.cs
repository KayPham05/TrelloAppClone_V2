namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisBreakdownDto
    {
        public string Name { get; set; } = string.Empty;
        public int TotalCards { get; set; }
        public int CompletedCards { get; set; }
        public int OverdueCards { get; set; }
    }
}
