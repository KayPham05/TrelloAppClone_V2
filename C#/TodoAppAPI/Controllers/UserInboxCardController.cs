using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

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
        [HttpGet("{userUId}")]
        public async Task<IActionResult> GetUserInboxCards(string userUId)
        {
            var cards = await _userInboxCard.GetCardInbox(userUId);
            return Ok(cards);
        }

        [HttpPost("{userUId}")]
        public async Task<IActionResult> AddUserInboxCard(string userUId ,[FromQuery] string cardUId )
        {
            var result = await _userInboxCard.AddCardInbox(userUId, cardUId);
            if (result)
            {
                _ = _activity.AddActivity(userUId, $"add card '{cardUId}' to inbox");
                return Ok(new { message = "Thêm card vào inbox thành công" }); 
            }
            return StatusCode(500, new { message = "Lỗi khi thêm card vào inbox" });
        }
    }
}
