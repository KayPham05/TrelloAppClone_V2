using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
        public TodoItemController(ITodoItemService todoItemService)
        {
            _todoItemService = todoItemService;
        }
        [HttpPost("add")]
        public async Task<IActionResult> AddTodoItem([FromBody] AddTodoItemRequest request)
        {
            if (string.IsNullOrEmpty(request.CardUId) || string.IsNullOrEmpty(request.Content))
                return BadRequest("Thiếu thông tin cardUId hoặc nội dung.");

            var success = await _todoItemService.AddTodoItem(request.CardUId, request.Content);
            if (success)
                return Ok(new { message = "Thêm todo item thành công" });
            
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
                return Ok("Cập nhật trạng thái thành công.");

            return NotFound(" Không tìm thấy todo item để cập nhật.");
        }

        [HttpDelete("{todoItemUId}")]
        public async Task<IActionResult> DeleteTodoItem(string todoItemUId)
        {
            var success = await _todoItemService.DeleteTodoItem(todoItemUId);
            if (success)
                return Ok("Xóa todo item thành công.");

            return NotFound("Không tìm thấy todo item để xóa.");
        }
    }

}

