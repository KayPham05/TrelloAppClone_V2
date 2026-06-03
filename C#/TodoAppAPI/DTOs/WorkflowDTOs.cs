namespace TodoAppAPI.DTOs
{
    // ── Response DTOs ─────────────────────────────────────────────────────────

    public class WorkflowNodeDto
    {
        public string WorkflowNodeUId { get; set; } = string.Empty;
        public string NodeType { get; set; } = string.Empty;
        public string? ReferenceId { get; set; }
        public double PositionX { get; set; }
        public double PositionY { get; set; }
        // Denormalized board info (filled by controller)
        public string? BoardName { get; set; }
        public string? BoardStatus { get; set; }
    }

    public class WorkflowEdgeDto
    {
        public string WorkflowEdgeUId { get; set; } = string.Empty;
        public string SourceNodeUId { get; set; } = string.Empty;
        public string TargetNodeUId { get; set; } = string.Empty;
        public string EdgeType { get; set; } = string.Empty;
        public string? Label { get; set; }
        public bool IsReversed { get; set; }
    }

    public class WorkflowDesignDto
    {
        public string WorkflowDesignUId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<WorkflowNodeDto> Nodes { get; set; } = [];
        public List<WorkflowEdgeDto> Edges { get; set; } = [];
    }

    // ── Request DTOs ──────────────────────────────────────────────────────────

    public class CreateWorkflowDesignRequest
    {
        public string WorkspaceUId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? CreatedByUserUId { get; set; }
    }

    public class AddWorkflowNodeRequest
    {
        public string WorkflowDesignUId { get; set; } = string.Empty;
        public string NodeType { get; set; } = "Board";
        public string? ReferenceId { get; set; }
        public double PositionX { get; set; } = 0;
        public double PositionY { get; set; } = 0;
    }

    public class UpdateNodePositionRequest
    {
        public double PositionX { get; set; }
        public double PositionY { get; set; }
    }

    public class AddWorkflowEdgeRequest
    {
        public string WorkflowDesignUId { get; set; } = string.Empty;
        public string SourceNodeUId { get; set; } = string.Empty;
        public string TargetNodeUId { get; set; } = string.Empty;
        public string EdgeType { get; set; } = "dependency";
        public string? Label { get; set; }
        public bool IsReversed { get; set; } = false;
    }

    public class UpdateEdgeRequest
    {
        public string? Label { get; set; }
        public bool IsReversed { get; set; }
        public string EdgeType { get; set; } = "dependency";
    }
}
