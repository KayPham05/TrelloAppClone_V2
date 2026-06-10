using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Models;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Hubs;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/workflow")]
    [ApiController]
    [Authorize]
    public class WorkflowController : ControllerBase
    {
        private readonly TodoDbContext _context;
        private readonly IHubContext<NotificationHub> _notificationHubContext;

        public WorkflowController(TodoDbContext context, IHubContext<NotificationHub> notificationHubContext)
        {
            _context = context;
            _notificationHubContext = notificationHubContext;
        }

        // GET v1/api/workflow/{workspaceId}
        // Returns the workflow design (nodes + edges) for a workspace.
        // Creates an empty one if none exists yet.
        [HttpGet("{workspaceId}")]
        public async Task<IActionResult> GetWorkflow(string workspaceId)
        {
            var design = await _context.WorkflowDesigns
                .Include(d => d.Nodes)
                .Include(d => d.Edges)
                .FirstOrDefaultAsync(d => d.WorkspaceUId == workspaceId);

            if (design == null)
                return Ok(new WorkflowDesignDto { WorkflowDesignUId = string.Empty, Name = "Workflow" });

            // Collect referenced board IDs to fetch board names in one query
            var boardIds = design.Nodes!
                .Where(n => n.NodeType == "Board" && n.ReferenceId != null)
                .Select(n => n.ReferenceId!)
                .ToList();

            var boards = await _context.Boards
                .Where(b => boardIds.Contains(b.BoardUId))
                .ToDictionaryAsync(b => b.BoardUId, b => b);

            var dto = new WorkflowDesignDto
            {
                WorkflowDesignUId = design.WorkflowDesignUId,
                Name = design.Name,
                Description = design.Description,
                Nodes = design.Nodes!.Select(n =>
                {
                    boards.TryGetValue(n.ReferenceId ?? string.Empty, out var board);
                    return new WorkflowNodeDto
                    {
                        WorkflowNodeUId = n.WorkflowNodeUId,
                        NodeType = n.NodeType,
                        ReferenceId = n.ReferenceId,
                        PositionX = n.PositionX,
                        PositionY = n.PositionY,
                        BoardName = board?.BoardName,
                        BoardStatus = board?.Status
                    };
                }).ToList(),
                Edges = design.Edges!.Select(e => new WorkflowEdgeDto
                {
                    WorkflowEdgeUId = e.WorkflowEdgeUId,
                    SourceNodeUId = e.SourceNodeUId,
                    TargetNodeUId = e.TargetNodeUId,
                    EdgeType = e.EdgeType,
                    Label = e.Label,
                    IsReversed = e.IsReversed
                }).ToList()
            };

            return Ok(dto);
        }

        // POST v1/api/workflow
        // Creates a new workflow design for a workspace.
        [HttpPost]
        public async Task<IActionResult> CreateWorkflow([FromBody] CreateWorkflowDesignRequest request)
        {
            if (string.IsNullOrEmpty(request.WorkspaceUId) || string.IsNullOrEmpty(request.Name))
                return BadRequest("WorkspaceUId and Name are required.");

            var existing = await _context.WorkflowDesigns
                .AnyAsync(d => d.WorkspaceUId == request.WorkspaceUId);
            if (existing)
                return Conflict(new { message = "A workflow design already exists for this workspace." });

            var design = new WorkflowDesign
            {
                WorkspaceUId = request.WorkspaceUId,
                Name = request.Name,
                Description = request.Description,
                CreatedByUserUId = request.CreatedByUserUId
            };

            _context.WorkflowDesigns.Add(design);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetWorkflow),
                new { workspaceId = request.WorkspaceUId },
                new { design.WorkflowDesignUId });
        }

        // POST v1/api/workflow/{designId}/nodes
        // Adds a node to an existing workflow design.
        [HttpPost("{designId}/nodes")]
        public async Task<IActionResult> AddNode(string designId, [FromBody] AddWorkflowNodeRequest request)
        {
            var design = await _context.WorkflowDesigns.FindAsync(designId);
            if (design == null) return NotFound("Workflow design not found.");

            var node = new WorkflowNode
            {
                WorkflowDesignUId = designId,
                NodeType = request.NodeType,
                ReferenceId = request.ReferenceId,
                PositionX = request.PositionX,
                PositionY = request.PositionY
            };

            _context.WorkflowNodes.Add(node);
            await _context.SaveChangesAsync();

            await _notificationHubContext.Clients.All.SendAsync("WorkspaceWorkflowUpdated", new { workspaceId = design.WorkspaceUId });

            return CreatedAtAction(nameof(GetWorkflow),
                new { workspaceId = design.WorkspaceUId },
                new { node.WorkflowNodeUId });
        }

        // PATCH v1/api/workflow/nodes/{nodeId}/position
        // Updates only the canvas position of a node (called on drag-end).
        [HttpPatch("nodes/{nodeId}/position")]
        public async Task<IActionResult> UpdateNodePosition(string nodeId, [FromBody] UpdateNodePositionRequest request)
        {
            var node = await _context.WorkflowNodes.FindAsync(nodeId);
            if (node == null) return NotFound("Node not found.");

            node.PositionX = request.PositionX;
            node.PositionY = request.PositionY;
            await _context.SaveChangesAsync();

            var design = await _context.WorkflowDesigns.FindAsync(node.WorkflowDesignUId);
            if (design != null)
            {
                await _notificationHubContext.Clients.All.SendAsync("WorkspaceWorkflowUpdated", new { workspaceId = design.WorkspaceUId });
            }

            return Ok(new { message = "Position updated." });
        }

        // DELETE v1/api/workflow/nodes/{nodeId}
        // Deletes a node (and its connected edges via NoAction — edges deleted explicitly).
        [HttpDelete("nodes/{nodeId}")]
        public async Task<IActionResult> DeleteNode(string nodeId)
        {
            var node = await _context.WorkflowNodes.FindAsync(nodeId);
            if (node == null) return NotFound("Node not found.");

            // Remove edges connected to this node first to avoid FK violation
            var edges = _context.WorkflowEdges
                .Where(e => e.SourceNodeUId == nodeId || e.TargetNodeUId == nodeId);
            _context.WorkflowEdges.RemoveRange(edges);

            _context.WorkflowNodes.Remove(node);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Node deleted." });
        }

        // POST v1/api/workflow/edges
        // Adds a directed edge between two nodes.
        [HttpPost("edges")]
        public async Task<IActionResult> AddEdge([FromBody] AddWorkflowEdgeRequest request)
        {
            if (request.SourceNodeUId == request.TargetNodeUId)
                return BadRequest("Self-referencing edges are not allowed.");

            var duplicate = await _context.WorkflowEdges.AnyAsync(
                e => e.SourceNodeUId == request.SourceNodeUId &&
                     e.TargetNodeUId == request.TargetNodeUId);
            if (duplicate)
                return Conflict(new { message = "Edge already exists." });

            var sourceExists = await _context.WorkflowNodes.AnyAsync(n => n.WorkflowNodeUId == request.SourceNodeUId);
            var targetExists = await _context.WorkflowNodes.AnyAsync(n => n.WorkflowNodeUId == request.TargetNodeUId);
            if (!sourceExists || !targetExists)
                return BadRequest("Source or target node not found.");

            var edge = new WorkflowEdge
            {
                WorkflowDesignUId = request.WorkflowDesignUId,
                SourceNodeUId = request.SourceNodeUId,
                TargetNodeUId = request.TargetNodeUId,
                EdgeType = request.EdgeType,
                Label = request.Label,
                IsReversed = request.IsReversed
            };

            _context.WorkflowEdges.Add(edge);
            await _context.SaveChangesAsync();

            return Created(string.Empty, new { edge.WorkflowEdgeUId });
        }

        // PATCH v1/api/workflow/edges/{edgeId}
        // Updates label, direction, or type for an edge.
        [HttpPatch("edges/{edgeId}")]
        public async Task<IActionResult> UpdateEdge(string edgeId, [FromBody] UpdateEdgeRequest request)
        {
            var edge = await _context.WorkflowEdges.FindAsync(edgeId);
            if (edge == null) return NotFound("Edge not found.");

            edge.Label = request.Label;
            edge.IsReversed = request.IsReversed;
            edge.EdgeType = request.EdgeType;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Edge updated." });
        }

        // DELETE v1/api/workflow/edges/{edgeId}
        [HttpDelete("edges/{edgeId}")]
        public async Task<IActionResult> DeleteEdge(string edgeId)
        {
            var edge = await _context.WorkflowEdges.FindAsync(edgeId);
            if (edge == null) return NotFound("Edge not found.");

            _context.WorkflowEdges.Remove(edge);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Edge deleted." });
        }
    }
}
