namespace TodoAppAPI.Models
{
    public class WorkflowEdge
    {
        public string WorkflowEdgeUId { get; set; } = Guid.NewGuid().ToString();

        // Edge type: "dependency", "reference"
        public string EdgeType { get; set; } = "dependency";

        // Optional label / condition shown on the edge
        public string? Label { get; set; }

        // When true, the arrow points from Target → Source instead
        public bool IsReversed { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // FK - WorkflowDesign (for cascade delete)
        public string WorkflowDesignUId { get; set; } = string.Empty;
        public virtual WorkflowDesign? WorkflowDesign { get; set; }

        // FK - Source Node
        public string SourceNodeUId { get; set; } = string.Empty;
        public virtual WorkflowNode? SourceNode { get; set; }

        // FK - Target Node
        public string TargetNodeUId { get; set; } = string.Empty;
        public virtual WorkflowNode? TargetNode { get; set; }
    }
}
