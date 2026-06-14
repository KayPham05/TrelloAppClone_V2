using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.DTOs.Comments;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

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
        private readonly ICloudinaryService _cloudinaryService;

        public CommentsController(
            ICommentService service,
            IActivity activity,
            IHubContext<BoardHub> boardHubContext,
            ICardsService cardService,
            IListService listService,
            ICloudinaryService cloudinaryService)
        {
            _service = service;
            _activity = activity;
            _boardHubContext = boardHubContext;
            _cardService = cardService;
            _listService = listService;
            _cloudinaryService = cloudinaryService;
        }

        [HttpGet("card/{cardUId}")]
        public async Task<IActionResult> GetCommentsByCard(string cardUId)
        {
            var comments = await _service.GetCommentsByCardAsync(cardUId);
            return Ok(comments.Select(CommentResponseDto.FromEntity));
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var comment = await _service.GetByIdAsync(id);
            if (comment == null) return NotFound();
            return Ok(CommentResponseDto.FromEntity(comment));
        }

        [HttpPost]
        public async Task<IActionResult> Add(CommentCreateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.CardUId) ||
                string.IsNullOrWhiteSpace(request.UserUId) ||
                string.IsNullOrWhiteSpace(request.Content))
            {
                return BadRequest("Card, user, and comment content are required.");
            }

            var comment = new Comment
            {
                CardUId = request.CardUId,
                UserUId = request.UserUId,
                Content = request.Content.Trim()
            };

            var added = await _service.AddCommentAsync(comment);
            if (added == null) return BadRequest("KhÃ´ng thá»ƒ thÃªm comment");

            _ = _activity.AddActivity(request.UserUId, $"added a comment to card '{request.CardUId}'");
            await BroadcastCommentAsync("CommentAdded", added);
            return Ok(CommentResponseDto.FromEntity(added));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, CommentUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.UserUId) ||
                string.IsNullOrWhiteSpace(request.Content))
            {
                return BadRequest("User and comment content are required.");
            }

            var existing = await _service.GetByIdAsync(id);
            if (existing == null) return NotFound("KhÃ´ng tÃ¬m tháº¥y comment");
            if (existing.UserUId != request.UserUId) return Forbid();

            existing.Content = request.Content.Trim();
            var ok = await _service.UpdateCommentAsync(existing);
            if (!ok) return NotFound("KhÃ´ng tÃ¬m tháº¥y comment hoáº·c cáº­p nháº­t tháº¥t báº¡i");

            var updated = await _service.GetByIdAsync(id);
            if (updated == null) return NotFound("KhÃ´ng tÃ¬m tháº¥y comment");

            _ = _activity.AddActivity(request.UserUId, $"updated a comment in card '{updated.CardUId}'");
            await BroadcastCommentAsync("CommentUpdated", updated);
            return Ok(CommentResponseDto.FromEntity(updated));
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id, [FromQuery] string userUId)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest("userUId is required.");

            var comment = await _service.GetByIdAsync(id);
            if (comment == null)
                return NotFound("KhÃ´ng tÃ¬m tháº¥y comment");
            if (comment.UserUId != userUId)
                return Forbid();

            var cardUId = comment.CardUId;
            var ok = await _service.DeleteCommentAsync(id);
            if (!ok)
                return BadRequest("KhÃ´ng thá»ƒ xÃ³a comment");

            _ = _activity.AddActivity(userUId, "deleted a comment");

            var card = _cardService.GetById(cardUId);
            if (card != null && !string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CommentDeleted", new { commentUId = id, cardUId, boardUId = list.BoardUId });
                }
            }

            return Ok(new { message = "XÃ³a comment thÃ nh cÃ´ng" });
        }

        [HttpPost("{id}/attachments")]
        public async Task<IActionResult> UploadAttachment(
            string id,
            IFormFile file,
            [FromQuery] string userUId,
            [FromForm] string? description = null)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest("userUId is required.");
            if (file == null || file.Length == 0)
                return BadRequest("File khÃ´ng há»£p lá»‡ hoáº·c rá»—ng.");

            var uploadResult = await _cloudinaryService.UploadFileAsync(file);
            if (uploadResult == null)
                return StatusCode(500, "Lá»—i khi upload file lÃªn Cloudinary.");

            var attachment = await _service.AddAttachmentAsync(
                id,
                uploadResult.Value.Url,
                uploadResult.Value.FileName,
                userUId,
                description);

            if (attachment == null)
                return NotFound("KhÃ´ng tÃ¬m tháº¥y comment hoáº·c báº¡n khÃ´ng cÃ³ quyá»n.");

            _ = _activity.AddActivity(userUId, $"attached file '{attachment.FileName}' to comment '{id}'");
            return Ok(new CommentAttachmentResponseDto
            {
                AttachmentUId = attachment.AttachmentUId,
                Url = attachment.Url,
                FileName = attachment.FileName,
                Description = attachment.Description,
                CreatedAt = attachment.CreatedAt
            });
        }

        [HttpDelete("{id}/attachments/{attachmentUId}")]
        public async Task<IActionResult> DeleteAttachment(string id, string attachmentUId, [FromQuery] string userUId)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest("userUId is required.");

            var ok = await _service.RemoveAttachmentAsync(attachmentUId, userUId);
            if (!ok)
                return NotFound("KhÃ´ng tÃ¬m tháº¥y tá»‡p Ä‘Ã­nh kÃ¨m hoáº·c báº¡n khÃ´ng cÃ³ quyá»n.");

            _ = _activity.AddActivity(userUId, $"deleted attachment '{attachmentUId}' from comment '{id}'");
            return Ok(new { message = "XÃ³a tá»‡p Ä‘Ã­nh kÃ¨m comment thÃ nh cÃ´ng" });
        }

        private async Task BroadcastCommentAsync(string eventName, Comment comment)
        {
            var card = _cardService.GetById(comment.CardUId);
            if (card == null || string.IsNullOrEmpty(card.ListUId))
                return;

            var list = await _listService.GetListByIdAsync(card.ListUId);
            if (list == null)
                return;

            await _boardHubContext.Clients
                .Group(BoardHub.BoardGroup(list.BoardUId))
                .SendAsync(eventName, CommentResponseDto.FromEntity(comment));
        }
    }
}
