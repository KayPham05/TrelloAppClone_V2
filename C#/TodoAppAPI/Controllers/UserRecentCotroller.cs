using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/RecentBoard")]
    [ApiController]
    [Authorize]
    public class UserRecentCotroller : ControllerBase
    {
        private readonly IUserRecentBoardService _userRecentBoardService;
        public UserRecentCotroller(IUserRecentBoardService userRecentBoardService)
        {
            _userRecentBoardService = userRecentBoardService;
        }
        [HttpGet]
        public async Task<IActionResult> GetUserRecentBoard(string userUId) {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest("userUId null");
            var boards = await _userRecentBoardService.GetRecentBoardByUserUId(userUId);
            return Ok(boards);
        }

        [HttpPost("{userUId}")]
        public async Task<IActionResult> SaveRecent(string userUId, [FromQuery] string boardUId)
        {
            if (string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(boardUId))
                return BadRequest("Thieu userUId or boardUId");
            var result = await _userRecentBoardService.SaveRecentBoard(userUId, boardUId);
            if (!result)
                return BadRequest("Khong the them");
            return Ok(result);
            
        }
    }
}
