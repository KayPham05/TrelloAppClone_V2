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
        public CardMemberController(ICardMemberService cardMemberService, IActivity activity)
        {
            _cardMemberService = cardMemberService;
            _activity = activity;
        }

        [HttpGet("{cardUId}")]
        public async Task<IActionResult> GetAllMembersByCardUId(string cardUId)
        {
            if (string.IsNullOrEmpty(cardUId))
                return BadRequest("CardUId không được để trống.");

            var members = await _cardMemberService.GetAllUserMemberByCardUId(cardUId);

            if (members == null)
                return NotFound("Không có thành viên nào trong card này.");

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
                return Forbid("Không thể thêm thành viên (không có quyền hoặc dữ liệu không hợp lệ).");
            _ = _activity.AddActivity(requesterUId, $"added user '{userUId}' to card '{cardUId}'");
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
                return Forbid("Không thể xóa thành viên (không có quyền hoặc không tồn tại).");
            _ = _activity.AddActivity(requesterUId, $"removed user '{userUId}' from card '{cardUId}'");
            return Ok(new { message = "Xóa thành viên khỏi card thành công." });
        }
    }
}
