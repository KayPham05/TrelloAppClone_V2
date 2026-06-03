namespace TodoAppAPI.DTOs.ProjectAnalysis
{
    public static class ProjectAnalysisValues
    {
        public static readonly string[] ScopeTypes = ["workspace", "board", "card"];
        public static readonly string[] Levels = ["low", "medium", "high"];
        public static readonly string[] MilestoneStatuses = ["onTrack", "atRisk", "done"];
    }
}
