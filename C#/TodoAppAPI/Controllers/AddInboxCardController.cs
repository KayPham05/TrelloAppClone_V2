using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/add-inbox-card")]
    [ApiController]
    [Authorize]
    public class AddInboxCardController : ControllerBase
    {
        private readonly IAddInboxCardService _addInboxCardService;
        private readonly IActivity _activity;
        public AddInboxCardController(IAddInboxCardService addInboxCardService, IActivity activity)
        {
            _addInboxCardService = addInboxCardService;
            _activity = activity;
        }
        [HttpPost]
        public async Task<IActionResult> AddInboxCardUser([FromBody] AddInboxCard addInboxCard)
        {
            if (addInboxCard == null)
                return BadRequest("boardUId is required");
            var result = await _addInboxCardService.AddCardToInbox(addInboxCard);
            if (!result)
                return StatusCode(500, new { message = "Lỗi khi thêm Inbox Card." });
            _ = _activity.AddActivity(addInboxCard.UserUId, $"added card '{addInboxCard.Card?.Title}' to inbox");
            return Ok(new { message = "Thêm Inbox Card thành công." });
        }
    }
}
