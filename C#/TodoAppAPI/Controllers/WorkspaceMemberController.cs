using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    /// <summary>
    /// Dedicated controller for Workspace Member CRUD.
    /// Endpoints are grouped under v1/api/workspaceMember
    /// </summary>
    [Route("v1/api/workspaceMember")]
    [ApiController]
    [Authorize]
    public class WorkspaceMemberController : ControllerBase
    {
        private readonly IWorkspaceService _workspaceService;
        private readonly IActivity _activity;

        public WorkspaceMemberController(IWorkspaceService workspaceService, IActivity activity)
        {
            _workspaceService = workspaceService;
            _activity = activity;
        }

        // GET v1/api/workspaceMember/{workspaceId}
        [HttpGet("{workspaceId}")]
        public async Task<IActionResult> GetMembers(string workspaceId)
        {
            var members = await _workspaceService.GetWorkspaceMembers(workspaceId);
            return Ok(members);
        }

        // POST v1/api/workspaceMember/{workspaceId}/invite
        [HttpPost("{workspaceId}/invite")]
        public async Task<IActionResult> InviteMember(string workspaceId, [FromBody] InviteUser dto)
        {
            if (dto == null || string.IsNullOrEmpty(dto.UserId) || string.IsNullOrEmpty(dto.RequesterUId))
                return BadRequest("Thiếu thông tin lời mời.");

            var success = await _workspaceService.InviteUserToWorkspace(
                workspaceId,
                dto.UserId,
                dto.RequesterUId,
                dto.Role
            );

            if (!success)
                return StatusCode(403, new { message = "Bạn không có quyền mời hoặc người dùng đã tồn tại trong workspace." });

            _ = _activity.AddActivity(dto.RequesterUId, $"invited user '{dto.UserId}' to workspace '{workspaceId}' with role '{dto.Role}'");
            return Ok(new
            {
                message = $"Đã mời người dùng thành công với quyền {dto.Role}",
                invitedUserId = dto.UserId
            });
        }

        // PUT v1/api/workspaceMember/{workspaceId}/role/{userId}
        [HttpPut("{workspaceId}/role/{userId}")]
        public async Task<IActionResult> UpdateMemberRole(string workspaceId, string userId, [FromQuery] string newRole, [FromQuery] string requesterUId)
        {
            if (string.IsNullOrEmpty(newRole) || string.IsNullOrEmpty(requesterUId))
                return BadRequest("Thiếu newRole hoặc requesterUId.");

            var success = await _workspaceService.UpdateMemberRole(workspaceId, userId, newRole, requesterUId);

            if (!success)
                return StatusCode(403, new { message = "Bạn không có quyền thực hiện hành động này hoặc dữ liệu không hợp lệ." });

            _ = _activity.AddActivity(requesterUId, $"updated role of user '{userId}' in workspace '{workspaceId}' to '{newRole}'");
            return Ok(new { message = "Cập nhật vai trò thành viên thành công!" });
        }

        // DELETE v1/api/workspaceMember/{workspaceId}/{userId}
        [HttpDelete("{workspaceId}/{userId}")]
        public async Task<IActionResult> RemoveMember(string workspaceId, string userId, [FromQuery] string requesterUId)
        {
            if (string.IsNullOrEmpty(requesterUId))
                return BadRequest("Thiếu requesterUId.");

            var success = await _workspaceService.RemoveMemberFromWorkspace(workspaceId, userId, requesterUId);

            if (!success)
                return StatusCode(403, new { message = "Bạn không có quyền xóa thành viên này hoặc thao tác không hợp lệ." });

            _ = _activity.AddActivity(requesterUId, $"removed user '{userId}' from workspace '{workspaceId}'");
            return Ok(new { message = "Đã xóa thành viên khỏi workspace thành công!" });
        }
    }
}
