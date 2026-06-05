namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public class ProjectAnalysisSnapshotDto
    {
        public string ScopeType { get; set; } = string.Empty;
        public string ScopeUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public List<ProjectAnalysisSnapshotListDto> Lists { get; set; } = [];
        public List<ProjectAnalysisSnapshotCardDto> Cards { get; set; } = [];
    }

    public class ProjectAnalysisSnapshotListDto
    {
        public string ListUId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public int Position { get; set; }
    }

    public class ProjectAnalysisSnapshotCardDto
    {
        public string CardUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? ListUId { get; set; }
        public string ListName { get; set; } = string.Empty;
        public string? Status { get; set; }
        public DateTime? DueDate { get; set; }
        public int Position { get; set; }
        public int TotalTodoItems { get; set; }
        public int CompletedTodoItems { get; set; }
        public List<string> LabelNames { get; set; } = [];
    }
}
