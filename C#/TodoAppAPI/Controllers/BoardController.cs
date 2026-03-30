using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/boards")]
    [ApiController]
    [Authorize]
    public class BoardController : ControllerBase
    {
        private readonly IBoardService _boardService;
        private readonly IActivity _activity;
        public BoardController(IBoardService boardService, IActivity activity)
        {
            _boardService = boardService;
            _activity = activity;
        }


        [HttpGet]
        public async Task<IActionResult> GetAllBoards([FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest("userUId is required");
            var boards = await _boardService.GetAllBoardsByUserAsync(userUId);
            return Ok(boards);
        }

        [HttpGet("{uid}")]
        public async Task<IActionResult> GetBoardById(string uid)
        {
            var board = await _boardService.GetBoardByIdAsync(uid);
            if (board == null)
                return NotFound(new { message = "Board không tồn tại." });
            _ = _activity.AddActivity(board.UserUId, $"viewed board '{board.BoardName}'");
            return Ok(board);
        }

        [HttpPost]
        public async Task<IActionResult> CreateBoard([FromBody] Board board)
        {
            if (board == null || string.IsNullOrEmpty(board.BoardName))
                return BadRequest("Thiếu thông tin board.");

            board.BoardName = board.BoardName.Trim();
            board.Visibility = string.IsNullOrEmpty(board.Visibility) ? "Private" : board.Visibility;

            var created = await _boardService.AddBoardAsync(board);
            if (created == null)
                return StatusCode(403, new { message = "Bạn không có quyền tạo board trong workspace này." });

            return Ok(new
            {
                message = "Tạo board thành công.",
                board = new
                {
                    created.BoardUId,
                    created.BoardName,
                    created.Visibility,
                    created.WorkspaceUId,
                    created.IsPersonal,
                    created.CreatedAt
                }
            });
        }


        [HttpPut("{uid}")]
        public async Task<IActionResult> UpdateBoard(string uid, [FromBody] Board board)
        {
            if (uid != board.BoardUId)
                return BadRequest(new { message = "UID không khớp." });

            var success = await _boardService.UpdateBoardAsync(board);
            if (!success)
                return NotFound(new { message = "Không tìm thấy board để cập nhật." });
            _ = _activity.AddActivity(board.UserUId, $"updated board '{board.BoardName}'");
            return Ok(new { message = "Cập nhật thành công." });
        }

 
        [HttpDelete("{uid}")]
        public async Task<IActionResult> DeleteBoard(string uid)
        {
            var success = await _boardService.DeleteBoardAsync(uid);
            if (!success)
                return NotFound(new { message = "Không tìm thấy board để xóa." });
            _ = _activity.AddActivity("System", $"deleted board with UID '{uid}'");
            return Ok(new { message = "Xóa thành công." });
        }
    }
}
