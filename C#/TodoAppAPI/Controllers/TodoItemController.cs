using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Hubs;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/todoItem")]
    [ApiController]
    [Authorize]
    public class TodoItemController : ControllerBase
    {
        private readonly ITodoItemService _todoItemService;
        private readonly IHubContext<BoardHub> _boardHubContext;
        private readonly ICardsService _cardService;
        private readonly IListService _listService;

        public TodoItemController(ITodoItemService todoItemService, IHubContext<BoardHub> boardHubContext, ICardsService cardService, IListService listService)
        {
            _todoItemService = todoItemService;
            _boardHubContext = boardHubContext;
            _cardService = cardService;
            _listService = listService;
        }
        [HttpPost("add")]
        public async Task<IActionResult> AddTodoItem([FromBody] AddTodoItemRequest request)
        {
            if (string.IsNullOrEmpty(request.CardUId) || string.IsNullOrEmpty(request.Content))
                return BadRequest("Thiếu thông tin cardUId hoặc nội dung.");

            var success = await _todoItemService.AddTodoItem(request.CardUId, request.Content);
            if (success)
            {
                var card = _cardService.GetById(request.CardUId);
                if (card != null && !string.IsNullOrEmpty(card.ListUId))
                {
                    var list = await _listService.GetListByIdAsync(card.ListUId);
                    if (list != null)
                    {
                        await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                            .SendAsync("TodoItemAdded", new { cardUId = request.CardUId, content = request.Content, boardUId = list.BoardUId });
                    }
                }
                return Ok(new { message = "Thêm todo item thành công" });
            }
            
            return StatusCode(500, "Lỗi khi thêm todo item.");
        }


        [HttpGet("{cardUId}")]
        public async Task<IActionResult> GetTodoItemsByCardUId(string cardUId)
        {
            var items = await _todoItemService.GetTodoItemByCardUId(cardUId);

            return Ok(items ?? new List<TodoItemDTO>());
        }

        [HttpPut("{todoItemUId}/update-status")]
        public async Task<IActionResult> UpdateStatus(string todoItemUId, [FromQuery] string status)
        {
            if (string.IsNullOrEmpty(status))
                return BadRequest("Thiếu tham số status.");

            var success = await _todoItemService.UpdateStatusTodoItem(todoItemUId, status);
            if (success)
            {
                var item = await _todoItemService.GetTodoItemById(todoItemUId);
                if (item != null)
                {
                    var card = _cardService.GetById(item.CardUId);
                    if (card != null && !string.IsNullOrEmpty(card.ListUId))
                    {
                        var list = await _listService.GetListByIdAsync(card.ListUId);
                        if (list != null)
                        {
                            await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                                .SendAsync("TodoItemStatusUpdated", new { todoItemUId, status, cardUId = item.CardUId, boardUId = list.BoardUId });
                        }
                    }
                }
                return Ok("Cập nhật trạng thái thành công.");
            }

            return NotFound(" Không tìm thấy todo item để cập nhật.");
        }

        [HttpDelete("{todoItemUId}")]
        public async Task<IActionResult> DeleteTodoItem(string todoItemUId)
        {
            var item = await _todoItemService.GetTodoItemById(todoItemUId);
            var success = await _todoItemService.DeleteTodoItem(todoItemUId);
            if (success)
            {
                if (item != null)
                {
                    var card = _cardService.GetById(item.CardUId);
                    if (card != null && !string.IsNullOrEmpty(card.ListUId))
                    {
                        var list = await _listService.GetListByIdAsync(card.ListUId);
                        if (list != null)
                        {
                            await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                                .SendAsync("TodoItemDeleted", new { todoItemUId, cardUId = item.CardUId, boardUId = list.BoardUId });
                        }
                    }
                }
                return Ok("Xóa todo item thành công.");
            }

            return NotFound("Không tìm thấy todo item để xóa.");
        }
    }

}

