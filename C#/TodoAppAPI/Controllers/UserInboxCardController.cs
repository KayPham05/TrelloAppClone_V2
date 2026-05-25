using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/user-inbox")]
    [ApiController]
    [Authorize]
    public class UserInboxCardController : ControllerBase
    {
        private readonly IUserInboxCard _userInboxCard;
        private readonly IActivity _activity;
        public UserInboxCardController(IUserInboxCard userInboxCard, IActivity activity)
        {
            _userInboxCard = userInboxCard;
            _activity = activity;
        }

        /// <summary>GET v1/api/user-inbox/{userUId} — lấy danh sách card trong inbox (sắp xếp theo Position)</summary>
        [HttpGet("{userUId}")]
        public async Task<IActionResult> GetUserInboxCards(string userUId)
        {
            var cards = await _userInboxCard.GetCardInbox(userUId);
            return Ok(cards);
        }

        /// <summary>POST v1/api/user-inbox/{userUId} — thêm card vào inbox (dùng khi tạo mới trực tiếp từ inbox)</summary>
        [HttpPost("{userUId}")]
        public async Task<IActionResult> AddUserInboxCard(string userUId, [FromQuery] string cardUId)
        {
            var result = await _userInboxCard.AddCardInbox(userUId, cardUId);
            if (result)
            {
                _ = _activity.AddActivity(userUId, $"add card '{cardUId}' to inbox");
                return Ok(new { message = "Thêm card vào inbox thành công" });
            }
            return StatusCode(500, new { message = "Lỗi khi thêm card vào inbox" });
        }

        /// <summary>
        /// POST v1/api/user-inbox/{userUId}/move/{cardId}?position=0
        /// Di chuyển card từ board sang inbox tại vị trí chỉ định.
        /// </summary>
        [HttpPost("{userUId}/move/{cardId}")]
        public async Task<IActionResult> MoveCardToInbox(string userUId, string cardId, [FromQuery] int position = 0)
        {
            var result = await _userInboxCard.MoveCardToInboxAsync(cardId, userUId, position);
            if (result)
            {
                _ = _activity.AddActivity(userUId, $"moved card '{cardId}' to inbox at position {position}");
                return Ok(new { message = "Đã chuyển card vào inbox" });
            }
            return StatusCode(500, new { message = "Lỗi khi chuyển card về inbox" });
        }

        /// <summary>
        /// PUT v1/api/user-inbox/{userUId}/reorder
        /// Cập nhật thứ tự các card trong inbox sau khi kéo-thả.
        /// Body: { items: [{ cardUId, position }] }
        /// </summary>
        [HttpPut("{userUId}/reorder")]
        public async Task<IActionResult> ReorderInboxCards(string userUId, [FromBody] InboxReorderRequest request)
        {
            var result = await _userInboxCard.ReorderInboxCardsAsync(userUId, request.Items);
            if (result)
                return Ok(new { message = "Đã cập nhật thứ tự inbox" });
            return StatusCode(500, new { message = "Lỗi khi reorder inbox" });
        }
    }
}
