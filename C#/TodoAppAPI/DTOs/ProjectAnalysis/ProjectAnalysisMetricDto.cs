namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisMetricDto
    {
        public int TotalCards { get; set; }
        public int TodoCards { get; set; }
        public int InProgressCards { get; set; }
        public int CompletedCards { get; set; }
        public int OtherCards { get; set; }
        public int OverdueCards { get; set; }
        public int DueSoonCards { get; set; }
        public int TotalTodoItems { get; set; }
        public int CompletedTodoItems { get; set; }
        public Dictionary<string, int> StatusDistribution { get; set; } = [];
    }
}
