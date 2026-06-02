namespace TodoAppAPI.Models
{
    public class WorkflowNode
    {
        public string WorkflowNodeUId { get; set; } = Guid.NewGuid().ToString();

        // Node type: "Board", "Note"
        public string NodeType { get; set; } = "Board";

        // ReferenceId = BoardUId when NodeType == "Board"
        public string? ReferenceId { get; set; }

        // Canvas position
        public double PositionX { get; set; } = 0;
        public double PositionY { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // FK - WorkflowDesign
        public string WorkflowDesignUId { get; set; } = string.Empty;
        public virtual WorkflowDesign? WorkflowDesign { get; set; }

        // Navigation - edges originating from this node
        public virtual ICollection<WorkflowEdge>? SourceEdges { get; set; }
        public virtual ICollection<WorkflowEdge>? TargetEdges { get; set; }
    }
}
