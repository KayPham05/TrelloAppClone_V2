using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/workspace")]
    [ApiController]
    [Authorize]
    public class WorkspaceController : ControllerBase
    {
        private readonly IWorkspaceService _workspaceService;
        private readonly IActivity _activity;
        private readonly ICloudinaryService _cloudinaryService;
        public WorkspaceController(IWorkspaceService workspaceService, IActivity activity, ICloudinaryService cloudinaryService)
        {
            _workspaceService = workspaceService;
            _activity = activity;
            _cloudinaryService = cloudinaryService;
        }
        [HttpPost("create")]
        public async Task<IActionResult> CreateWorkspace([FromQuery] string creatorUserId, [FromQuery] string name, [FromQuery] string? description = null)
        {
            if (string.IsNullOrEmpty(creatorUserId) || string.IsNullOrEmpty(name))
                return BadRequest("creatorUserId and name are required");
            var result = await _workspaceService.AddWorkspace(creatorUserId, name, description);
            if (!result)
                return StatusCode(500, new { message = "Error creating workspace." });
            _ = _activity.AddActivity(creatorUserId, $"created workspace '{name}'");
            return Ok(new { message = "Workspace created successfully." });
        }
        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteWorkspace([FromQuery] string workspaceId, [FromQuery] string requestUserId)
        {
            if (string.IsNullOrEmpty(workspaceId) || string.IsNullOrEmpty(requestUserId))
                return BadRequest("workspaceId and requestUserId are required");
            var result = await _workspaceService.DeleteWorkspace(workspaceId, requestUserId);
            if (!result)
                return Ok(new { message = "Không có quyền" });
            _ = _activity.AddActivity(requestUserId, $"deleted workspace '{workspaceId}'");
            return Ok(new { message = "Workspace deleted successfully." });
        }

        [HttpPut("update")]
        public async Task<IActionResult> UpdateWorkspace([FromBody] UpdateWorkspaceDTO dto)
        {
            if (string.IsNullOrEmpty(dto.WorkspaceId) || string.IsNullOrEmpty(dto.Name))
                return BadRequest("workspaceId and name are required");

            var result = await _workspaceService.UpdateWorkspace(
                dto.WorkspaceId, dto.Name, dto.Description, dto.RequesterUId
            );

            if (!result)
                return StatusCode(403, new { message = "Bạn không có quyền chỉnh sửa workspace này." });
            _ = _activity.AddActivity(dto.RequesterUId, $"updated workspace '{dto.WorkspaceId}'");
            return Ok(new { message = "Workspace updated successfully." });
        }





        [HttpGet]
        public async Task<IActionResult> GetAllWorkspaces([FromQuery] string userUid)
        {
            if (string.IsNullOrEmpty(userUid))
                return BadRequest("userUid is required");
            var workspaces = await _workspaceService.GetAllWorkspaces(userUid);
            return Ok(workspaces);
        }









        [HttpGet("{id}/boards")]
        public async Task<IActionResult> GetBoards(string id, string userUId)
        {
            var boards = await _workspaceService.GetWorkspaceBoards(id, userUId);
            return Ok(boards);
        }
    }
}
