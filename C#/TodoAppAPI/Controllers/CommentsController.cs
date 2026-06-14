using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Hubs;
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
        private readonly IHubContext<BoardHub> _boardHubContext;
        private readonly ICardsService _cardService;
        private readonly IListService _listService;
        public CommentsController(ICommentService service, IActivity activity, IHubContext<BoardHub> boardHubContext, ICardsService cardService, IListService listService)
        {
            _service = service;
            _activity = activity;
            _boardHubContext = boardHubContext;
            _cardService = cardService;
            _listService = listService;
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

            var card = _cardService.GetById(comment.CardUId);
            if (card != null && !string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId)).SendAsync("CommentAdded", added);
                }
            }
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

            var card = _cardService.GetById(comment.CardUId);
            if (card != null && !string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId)).SendAsync("CommentUpdated", comment);
                }
            }
            return Ok(comment);
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

            var card = _cardService.GetById(comment.CardUId);
            if (card != null && !string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CommentDeleted", new { commentUId = id, cardUId = comment.CardUId, boardUId = list.BoardUId });
                }
            }

            return Ok(new { message = "Xóa comment thành công" });
        }
    }
}
