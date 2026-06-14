using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/StarredBoard")]
    [ApiController]
    [Authorize]
    public class UserStarredBoardController : ControllerBase
    {
        private readonly IUserStarredBoardService _userStarredBoardService;

        public UserStarredBoardController(IUserStarredBoardService userStarredBoardService)
        {
            _userStarredBoardService = userStarredBoardService;
        }

        [HttpGet]
        public async Task<IActionResult> GetUserStarredBoard(string userUId)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest("userUId null");

            var boards = await _userStarredBoardService.GetStarredBoardByUserUId(userUId);
            return Ok(boards);
        }

        [HttpPut("{userUId}")]
        public async Task<IActionResult> SetStarred(string userUId, [FromQuery] string boardUId, [FromQuery] bool isStarred)
        {
            if (string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(boardUId))
                return BadRequest("Thieu userUId or boardUId");

            var result = await _userStarredBoardService.SetStarredBoard(userUId, boardUId, isStarred);
            if (!result)
                return StatusCode(403, new { message = "Khong the cap nhat dau sao cho board nay." });

            return Ok(new { isStarred });
        }
    }
}
