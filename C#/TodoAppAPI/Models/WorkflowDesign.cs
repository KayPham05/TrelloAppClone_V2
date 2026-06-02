namespace TodoAppAPI.Models
{
    public class WorkflowDesign
    {
        public string WorkflowDesignUId { get; set; } = Guid.NewGuid().ToString();
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        // FK - Workspace
        public string WorkspaceUId { get; set; } = string.Empty;
        public virtual Workspace? Workspace { get; set; }

        // FK - Creator
        public string? CreatedByUserUId { get; set; }
        public virtual User? CreatedBy { get; set; }

        // Navigation
        public virtual ICollection<WorkflowNode>? Nodes { get; set; }
        public virtual ICollection<WorkflowEdge>? Edges { get; set; }
    }
}
