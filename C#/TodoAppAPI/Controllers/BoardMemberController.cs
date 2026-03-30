using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/boardMember")]
    [ApiController]
    [Authorize]
    public class BoardMemberController : ControllerBase
    {
        private readonly IBoardMemberService _boardMemberService;
        private readonly IActivity _activity;
        public BoardMemberController(IBoardMemberService boardMemberService, IActivity activity)
        {
            _boardMemberService = boardMemberService;
            _activity = activity;
        }

        // Thêm thành viên vào board
        [HttpPost("{boardUId}/add")]
        public async Task<IActionResult> AddBoardMember(string boardUId, [FromQuery] string userUId, [FromQuery] string requesterUId, [FromQuery] string role)
        {
            if (string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(requesterUId) || string.IsNullOrEmpty(role))
                return BadRequest("Thiếu dữ liệu bắt buộc.");

            var success = await _boardMemberService.AddBoardMemberAsync(boardUId, userUId, requesterUId, role);
            if (!success)
                return Forbid("Không thể thêm thành viên. Kiểm tra quyền hoặc dữ liệu.");
            _ = _activity.AddActivity(requesterUId, $"added user '{userUId}' to board '{boardUId}' with role '{role}'");
            return Ok(new { message = $"Đã thêm thành viên vào board với quyền {role}." });
        }

        // Cập nhật quyền (role) của thành viên
        [HttpPut("{boardUId}/update-role")]
        public async Task<IActionResult> UpdateBoardMemberRole(string boardUId,[FromQuery] string userUId, [FromQuery] string newRole, [FromQuery] string requesterUId)
        {
            if (string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(newRole) || string.IsNullOrEmpty(requesterUId))
                return BadRequest("Thiếu dữ liệu bắt buộc.");

            var success = await _boardMemberService.UpdateBoardMemberRoleAsync(boardUId, userUId, newRole, requesterUId);
            if (!success)
                return Forbid("Không thể cập nhật quyền thành viên này.");
            _ = _activity.AddActivity(requesterUId, $"updated role of user '{userUId}' in board '{boardUId}' to '{newRole}'");
            return Ok(new { message = $"Đã cập nhật quyền thành viên thành {newRole}." });
        }

        // Xóa thành viên khỏi board
        [HttpDelete("{boardUId}/remove/{userUId}")]
        public async Task<IActionResult> RemoveBoardMember( string boardUId,  string userUId,[FromQuery] string requesterUId)
        {
            if (string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(requesterUId))
                return BadRequest("Thiếu dữ liệu bắt buộc.");

            var success = await _boardMemberService.RemoveBoardMemberAsync(boardUId, userUId, requesterUId);
            if (!success)
                return Forbid("Không thể xóa thành viên. Kiểm tra quyền hoặc dữ liệu.");
            _ = _activity.AddActivity(requesterUId, $"removed user '{userUId}' from board '{boardUId}'");
            return Ok(new { message = "Đã xóa thành viên khỏi board thành công." });
        }

        // Lấy danh sách thành viên của board
        [HttpGet("{boardUId}/members")]
        public async Task<IActionResult> GetBoardMembers(string boardUId)
        {
            if (string.IsNullOrEmpty(boardUId))
                return BadRequest("Thiếu thông tin boardUId.");

            var members = await _boardMemberService.GetBoardMembersAsync(boardUId);
            return Ok(members);
        }

        // Lấy vai trò của user trong board
        [HttpGet("{boardUId}/role")]
        public async Task<IActionResult> GetUserRoleInBoard( string boardUId,[FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(userUId))
                return BadRequest("Thiếu dữ liệu bắt buộc.");

            var role = await _boardMemberService.GetUserRoleInBoardAsync(boardUId, userUId);
            if (role == null)
                return NotFound("Không tìm thấy thành viên trong board.");

            return Ok(new { userUId, role });
        }

        // Kiểm tra quyền thao tác của user trong board (tuỳ mục đích frontend)
        [HttpGet("{boardUId}/has-permission")]
        public async Task<IActionResult> HasPermission( string boardUId, [FromQuery] string userUId, [FromQuery] string requiredRole)
        {
            if (string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(requiredRole))
                return BadRequest("Thiếu dữ liệu bắt buộc.");

            var hasPermission = await _boardMemberService.HasPermissionAsync(boardUId, userUId, requiredRole);
            return Ok(new { hasPermission });
        }
    }
}
