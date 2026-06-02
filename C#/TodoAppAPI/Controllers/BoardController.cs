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
        private readonly ICloudinaryService _cloudinaryService;
        private readonly ICardsService _cardsService;

        public BoardController(IBoardService boardService, IActivity activity, ICloudinaryService cloudinaryService, ICardsService cardsService)
        {
            _boardService = boardService;
            _activity = activity;
            _cloudinaryService = cloudinaryService;
            _cardsService = cardsService;
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
        public async Task<IActionResult> UpdateBoard(string uid, [FromBody] Board board, [FromQuery] string userUId)
        {
            if (uid != board.BoardUId)
                return BadRequest(new { message = "UID không khớp." });

            var success = await _boardService.UpdateBoardAsync(board, userUId);
            if (!success)
                return NotFound(new { message = "Không tìm thấy board để cập nhật hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId, $"updated board '{board.BoardName}'");
            return Ok(new { message = "Cập nhật thành công." });
        }

 
        [HttpDelete("{uid}")]
        public async Task<IActionResult> DeleteBoard(string uid, [FromQuery] string userUId)
        {
            var success = await _boardService.DeleteBoardAsync(uid, userUId);
            if (!success)
                return NotFound(new { message = "Không tìm thấy board để xóa hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId, $"deleted board with UID '{uid}'");
            return Ok(new { message = "Xóa thành công." });
        }

        [HttpPost("{uid}/upload-background")]
        public async Task<IActionResult> UploadBackground(string uid, IFormFile file, [FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId là bắt buộc." });

            var board = await _boardService.GetBoardByIdAsync(uid);
            if (board == null) return NotFound(new { message = "Board không tồn tại." });

            var result = await _cloudinaryService.UploadFileAsync(file);
            if (result == null) return BadRequest("Lỗi khi tải ảnh lên Cloudinary.");

            // Update board with new background URL (authorization checked inside UpdateBoardAsync)
            var boardToUpdate = new Board
            {
                BoardUId = uid,
                BoardName = board.BoardName,
                BackgroundUrl = result.Value.Url,
                UserUId = board.UserUId
            };
            
            var success = await _boardService.UpdateBoardAsync(boardToUpdate, userUId);
            if (!success)
                return StatusCode(403, new { message = "Bạn không có quyền thay đổi ảnh nền board này." });
            
            _ = _activity.AddActivity(userUId, $"updated background of board '{board.BoardName}'");
            return Ok(new { url = result.Value.Url });
        }

        // POST v1/api/boards/{boardUId}/archive-completed
        [HttpPost("{boardUId}/archive-completed")]
        public async Task<IActionResult> ArchiveCompletedCards(string boardUId, [FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId là bắt buộc." });

            var count = await _cardsService.ArchiveAllCompletedCardsAsync(boardUId, userUId);
            _ = _activity.AddActivity(userUId, $"archived {count} completed card(s) from board '{boardUId}'");
            return Ok(new { message = $"Đã lưu trữ {count} thẻ đã hoàn thành.", count });
        }
    }
}

