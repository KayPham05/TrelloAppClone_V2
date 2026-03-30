using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/comments")]
    [ApiController]
    [Authorize]
    public class CommentsController : ControllerBase
    {
        private readonly ICommentService _service;
        private readonly IActivity _activity;
        public CommentsController(ICommentService service, IActivity activity)
        {
            _service = service;
            _activity = activity;
        }

        // GET: api/<CommentController>
        [HttpGet("card/{cardUId}")]
        public async Task<IActionResult> GetCommentsByCard(string cardUId)
        {
            var comments = await _service.GetCommentsByCardAsync(cardUId);
            return Ok(comments);
        }

        //  Lấy comment theo ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var comment = await _service.GetByIdAsync(id);
            if (comment == null) return NotFound();
            return Ok(comment);
        }

        // Thêm comment mới
        [HttpPost]
        public async Task<IActionResult> Add(Comment comment)
        {
            var added = await _service.AddCommentAsync(comment);
            if (added == null) return BadRequest("Không thể thêm comment");
            _ = _activity.AddActivity(comment.UserUId, $"added a comment to card '{comment.CardUId}'");
            return Ok(added);
        }

        //  Sửa comment
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, Comment comment)
        {
            if (id != comment.CommentUId) return BadRequest();
            var ok = await _service.UpdateCommentAsync(comment);

            if (!ok)
                return NotFound("Không tìm thấy comment hoặc cập nhật thất bại");
            _ = _activity.AddActivity(comment.UserUId, $"updated a comment in card '{comment.CardUId}'");
            return ok ? Ok(comment) : NotFound();
        }

        // Xóa comment
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var comment = await _service.GetByIdAsync(id);
            if (comment == null)
                return NotFound("Không tìm thấy comment");

            var userUId = comment.UserUId;

            var ok = await _service.DeleteCommentAsync(id);
            if (!ok)
                return BadRequest("Không thể xóa comment");

            _ = _activity.AddActivity(userUId, "deleted a comment");

            return Ok(new { message = "Xóa comment thành công" });
        }
    }
}
