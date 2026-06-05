using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Hubs;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/lists")]
    [ApiController]
    [Authorize]
    public class ListController : ControllerBase
    {
        private readonly IListService _listService;
        private readonly IActivity _activity;
        private readonly IHubContext<BoardHub> _boardHubContext;
        public ListController(IListService listService, IActivity activity, IHubContext<BoardHub> boardHubContext)
        {
            _listService = listService;
            _activity = activity;
            _boardHubContext = boardHubContext;
        }
        // GET: api/<ListController>
        [HttpGet]
        public async Task<IActionResult> GetAllList([FromQuery] string boardUId)
        {
            if (string.IsNullOrEmpty(boardUId))
                return BadRequest("boardUId is required");
            var lists = await _listService.GetAllListsByBoardUidAsync(boardUId);
            return Ok(lists);
        }


        [HttpPost]
        public async Task<IActionResult> CreateList([FromBody] List list, [FromQuery] string userUId)
        {
            ModelState.Remove("ListUId");
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            if (string.IsNullOrEmpty(userUId))
                return BadRequest("userUId is required");

            var result = await _listService.AddListAsync(list, userUId);
            if (result == null)
                return StatusCode(403, new { message = "Lỗi khi tạo List hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId, $"created list '{list.ListName}'");
            
            var listDto = new ListDTO {
                ListUId = result.ListUId,
                ListName = result.ListName,
                Position = result.Position,
                Status = result.Status,
                CreatedAt = result.CreatedAt,
                BoardUId = result.BoardUId
            };
            
            await _boardHubContext.Clients.Group(BoardHub.BoardGroup(result.BoardUId)).SendAsync("ListCreated", listDto);
            
            return Ok(listDto);
        }

        [HttpPut("{listUId}")]
        public async Task<IActionResult> UpdateStatus(string listUId ,[FromQuery] string newStatus, [FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(newStatus))
                return BadRequest("newStatus is required");

            if (string.IsNullOrEmpty(userUId))
                return BadRequest("userUId is required");
            var existingList = await _listService.GetListByIdAsync(listUId);
            if (existingList == null)
                return NotFound(new { message = "Không tìm thấy list" });

            var list = new List
            {
                ListUId = listUId,
                Status = newStatus
            };

            var success = await _listService.UpdateStatus(list, userUId);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật status hoặc bạn không có quyền" });

            _ = _activity.AddActivity(userUId, $"updated list '{existingList.ListName}' status to '{newStatus}'");
            
            await _boardHubContext.Clients.Group(BoardHub.BoardGroup(existingList.BoardUId))
                .SendAsync("ListStatusUpdated", new { listUId = listUId, newStatus = newStatus, boardUId = existingList.BoardUId });

            return Ok(new {message = "cập nhật trạng thái thành công"});
        }

        [HttpPut("reorder")]
        public async Task<IActionResult> Reorder([FromBody] ReorderRequest req, [FromQuery] string userUId)
        {
            if (req == null || req.Order == null)
                return BadRequest("Invalid order");

            var ok = await _listService.UpdateListPositionAsync(req.BoardUId, req.Order, userUId);
            if (ok)
            {
                await _boardHubContext.Clients.Group(BoardHub.BoardGroup(req.BoardUId))
                    .SendAsync("ListReordered", new { boardUId = req.BoardUId, order = req.Order });
                return Ok();
            }
            return StatusCode(403, new { message = "Không thấy quyền hoặc lỗi server" });
        }


    }
}
 