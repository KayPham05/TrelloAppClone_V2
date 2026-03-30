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
        public WorkspaceController(IWorkspaceService workspaceService, IActivity activity)
        {
            _workspaceService = workspaceService;
            _activity = activity;
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
                return Forbid("Bạn không có quyền chỉnh sửa workspace này.");
            _ = _activity.AddActivity(dto.RequesterUId, $"updated workspace '{dto.WorkspaceId}'");
            return Ok(new { message = "Workspace updated successfully." });
        }

        [HttpPut("{workspaceUId}/update-role")]
        public async Task<IActionResult> UpdateMemberRole(string workspaceUId,[FromQuery] string targetUserUId,[FromQuery] string newRole,[FromQuery] string requesterUId)
        {
            var success = await _workspaceService.UpdateMemberRole(workspaceUId, targetUserUId, newRole, requesterUId);

            if (!success)
                return Forbid("Bạn không có quyền thực hiện hành động này hoặc dữ liệu không hợp lệ.");
            _ = _activity.AddActivity(requesterUId, $"updated role of user '{targetUserUId}' in workspace '{workspaceUId}' to '{newRole}'");
            return Ok(new { message = "Cập nhật vai trò thành viên thành công!" });
        }



        [HttpGet]
        public async Task<IActionResult> GetAllWorkspaces([FromQuery] string userUid)
        {
            if (string.IsNullOrEmpty(userUid))
                return BadRequest("userUid is required");
            var workspaces = await _workspaceService.GetAllWorkspaces(userUid);
            return Ok(workspaces);
        }


        [HttpPost("{workspaceId}/invite")]
        public async Task<IActionResult> InviteUserToWorkspace(string workspaceId, [FromBody] InviteUser dto)
        {
            if (dto == null || string.IsNullOrEmpty(dto.UserId) || string.IsNullOrEmpty(dto.RequesterUId))
                return BadRequest("Thiếu thông tin lời mời");

            var success = await _workspaceService.InviteUserToWorkspace(
                workspaceId,
                dto.UserId,
                dto.RequesterUId,
                dto.Role
            );

            if (!success)
                return Forbid("Bạn không có quyền mời hoặc người dùng đã tồn tại trong workspace");

            return Ok(new
            {
                message = $"Đã mời người dùng thành công với quyền {dto.Role}",
                invitedUserId = dto.UserId
            });
        }

        [HttpDelete("{workspaceId}/members/{userId}")]
        public async Task<IActionResult> RemoveMember( string workspaceId,  string userId, [FromQuery] string requesterUId)
        {
            if (string.IsNullOrEmpty(requesterUId))
                return BadRequest("Thiếu thông tin người thực hiện hành động");

            var success = await _workspaceService.RemoveMemberFromWorkspace(
                workspaceId,
                userId,
                requesterUId
            );

            if (!success)
                return Forbid("Bạn không có quyền xóa thành viên này hoặc thao tác không hợp lệ");
            _ = _activity.AddActivity(requesterUId, $"removed user '{userId}' from workspace '{workspaceId}'");
            return Ok(new { message = "Đã xóa thành viên khỏi workspace thành công!" });
        }


        [HttpGet("{id}/members")]
        public async Task<IActionResult> GetMembers(string id)
        {
            var members = await _workspaceService.GetWorkspaceMembers(id);
            return Ok(members);
        }

        [HttpGet("{id}/boards")]
        public async Task<IActionResult> GetBoards(string id, string userUId)
        {
            var boards = await _workspaceService.GetWorkspaceBoards(id, userUId);
            return Ok(boards);
        }
    }
}
