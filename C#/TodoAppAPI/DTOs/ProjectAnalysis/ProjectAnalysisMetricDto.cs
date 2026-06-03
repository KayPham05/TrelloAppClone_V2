namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisMetricDto
    {
        public int TotalCards { get; set; }
        public int CompletedCards { get; set; }
        public int OverdueCards { get; set; }
        public int TotalTodoItems { get; set; }
        public int CompletedTodoItems { get; set; }
    }
}
