using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/CardMember")]
    [ApiController]
    [Authorize]
    public class CardMemberController : ControllerBase
    {
        private readonly ICardMemberService _cardMemberService;
        private readonly IActivity _activity;
        private readonly IHubContext<BoardHub> _boardHubContext;
        public CardMemberController(ICardMemberService cardMemberService, IActivity activity, IHubContext<BoardHub> boardHubContext)
        {
            _cardMemberService = cardMemberService;
            _activity = activity;
            _boardHubContext = boardHubContext;
        }

        [HttpGet("{cardUId}")]
        public async Task<IActionResult> GetAllMembersByCardUId(string cardUId)
        {
            if (string.IsNullOrEmpty(cardUId))
                return BadRequest("CardUId không được để trống.");

            var members = await _cardMemberService.GetAllUserMemberByCardUId(cardUId);
            return Ok(members);
        }

        [HttpPost("add")]
        public async Task<IActionResult> AddCardMember([FromQuery] string userUId, [FromQuery] string requesterUId, [FromQuery] string boardUId, [FromQuery] string cardUId)
        {
            if (string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(requesterUId) ||
                string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(cardUId))
                return BadRequest("Thiếu tham số.");

            var result = await _cardMemberService.AddCardMember(userUId, requesterUId, boardUId, cardUId);

            if (!result)
                return StatusCode(403, new { message = "Không thể thêm thành viên (không có quyền hoặc dữ liệu không hợp lệ)." });
            _ = _activity.AddActivity(requesterUId, $"added user '{userUId}' to card '{cardUId}'");

            await _boardHubContext.Clients.Group(BoardHub.BoardGroup(boardUId))
                .SendAsync("CardMemberAdded", new { cardUId, userUId, boardUId });

            return Ok(new { message = "Thêm thành viên vào card thành công." });
        }

        [HttpDelete("remove")]
        public async Task<IActionResult> RemoveCardMember([FromQuery] string userUId, [FromQuery] string requesterUId, [FromQuery] string boardUId, [FromQuery] string cardUId)
        {
            if (string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(requesterUId) ||
                string.IsNullOrEmpty(boardUId) || string.IsNullOrEmpty(cardUId))
                return BadRequest("Thiếu tham số.");

            var result = await _cardMemberService.RemoveCardMember(userUId, requesterUId, boardUId, cardUId);

            if (!result)
                return StatusCode(403, new { message = "Không thể xóa thành viên (không có quyền hoặc không tồn tại)." });
            _ = _activity.AddActivity(requesterUId, $"removed user '{userUId}' from card '{cardUId}'");

            await _boardHubContext.Clients.Group(BoardHub.BoardGroup(boardUId))
                .SendAsync("CardMemberRemoved", new { cardUId, userUId, boardUId });

            return Ok(new { message = "Xóa thành viên khỏi card thành công." });
        }

        // Cập nhật role của thành viên trong card
        [HttpPut("{cardUId}/update-role")]
        public async Task<IActionResult> UpdateCardMemberRole(string cardUId, [FromQuery] string userUId, [FromQuery] string newRole, [FromQuery] string requesterUId)
        {
            if (string.IsNullOrEmpty(cardUId) || string.IsNullOrEmpty(userUId) ||
                string.IsNullOrEmpty(newRole) || string.IsNullOrEmpty(requesterUId))
                return BadRequest("Thiếu tham số.");

            var result = await _cardMemberService.UpdateCardMemberRole(cardUId, userUId, newRole, requesterUId);

            if (!result)
                return StatusCode(403, new { message = "Không thể cập nhật role (không có quyền hoặc dữ liệu không hợp lệ)." });

            _ = _activity.AddActivity(requesterUId, $"updated role of user '{userUId}' in card '{cardUId}' to '{newRole}'");
            return Ok(new { message = $"Đã cập nhật role thành viên thành {newRole}." });
        }
    }
}
