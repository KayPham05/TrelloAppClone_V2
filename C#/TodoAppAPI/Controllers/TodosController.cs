using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/cards")]
    [ApiController]
    [Authorize]
    public class TodosController : ControllerBase
    {
        private readonly ICardsService _cardService;
        private readonly IActivity _activity;
        private readonly ICloudinaryService _cloudinaryService;
        private readonly IUserInboxCard _userInboxCardService;

        public TodosController(ICardsService todosService, IActivity activity, ICloudinaryService cloudinaryService, IUserInboxCard userInboxCardService)
        {
            _cardService = todosService;
            _activity = activity;
            _cloudinaryService = cloudinaryService;
            _userInboxCardService = userInboxCardService;
        }

        // GET: api/<TodosController>
        [HttpGet("by-board/{boardUId}")]
        public IActionResult GetByBoard(string boardUId)
        {
            var cards = _cardService.GetCardsByBoardId(boardUId);
            return Ok(cards);
        }

        // GET api/<TodosController>/5
        [HttpGet("{id}")]
        public IActionResult Get(string id)
        {
            var card = _cardService.GetById(id);
            if (card == null) return NotFound("Card không tồn tại");
            return Ok(card);
        }

        // POST api/<TodosController>
        [HttpPost]
        public async Task<IActionResult> Add([FromBody] Card card)
        {
            if (await _cardService.AddCard(card))
            {
                _ = _activity.AddActivity(card.UserUId, $"added card '{card.Title}' to list '{card.ListUId}'");
                return Ok(card);
            }
                
            return BadRequest(new { message = "Không thể thêm card hoặc bạn không có quyền" });
        }

        [HttpPost("{userUId}/inbox")]
        public async Task<IActionResult> AddCardToInbox(string userUId, [FromBody] Card card)
        {
            if (card == null || string.IsNullOrEmpty(card.Title))
                return BadRequest("Thiếu thông tin card.");

            var createdCard = await _userInboxCardService.AddCardToInboxAsync(userUId, card);
            
            if (createdCard != null)
            {
                _ = _activity.AddActivity(userUId, $"added card '{createdCard.Title}' to inbox");
                return Ok(createdCard);
            }
                
            return StatusCode(500, "Không thể thêm card vào inbox");
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Card card, [FromQuery] string userUId)
        {
            card.CardUId = id;
            if (await _cardService.UpdateCard(card, userUId))
            {
                _ = _activity.AddActivity(userUId, $"updated card '{card.Title}' in list '{card.ListUId}'");
                return Ok("Cập nhật card thành công");
            }
                
            return NotFound("Card không tồn tại hoặc bạn không có quyền");
        }

        [HttpPut("inbox/{id}")]
        public async Task<IActionResult> UpdateInbox(string id, [FromBody] Card card, [FromQuery] string userUId)
        {
            if (await _userInboxCardService.UpdateInboxCardAsync(id, userUId, card))
            {
                _ = _activity.AddActivity(userUId, $"updated card '{card.Title}' in inbox");
                return Ok("Cập nhật card inbox thành công");
            }
            return NotFound("Card không tồn tại trong inbox hoặc bạn không có quyền");
        }

        // DELETE api/<TodosController>/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id, [FromQuery] string userUId)
        {
            var card = _cardService.GetById(id);
            if (card == null)
                return NotFound("Card không tồn tại");

            var cardName = card.Title;

            if (await _cardService.DeleteCard(id, userUId))
            {
                _ = _activity.AddActivity(userUId, $"deleted a card with id '{cardName}'");
                return Ok("Xóa card thành công");
            }
                
            return NotFound("Card không tồn tại hoặc bạn không có quyền");
        }

        [HttpGet("{id}/description")]
        public IActionResult GetDescription(string id)
        {
            var card = _cardService.GetById(id);
            if (card == null)
                return NotFound("Không tìm thấy card");

            return Ok(new { description = card.Description });
        }

        [HttpPut("{CardUId}/update-list")]
        public async Task<IActionResult> UpdateListUId(string CardUId, [FromBody] UpdateListRequest body)
        {
            var card = _cardService.GetById(CardUId);
            if (card == null)
                return NotFound("Card không tồn tại");

            var oldListUId = card.ListUId;

            var success = await _cardService.UpdateListUid(CardUId, body.ListUId, body.UserUId);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật ListUId cho Card." });

            _ = _activity.AddActivity(body.UserUId,
                $"moved card '{card.Title}' to another list");

            return Ok(new { message = "Cập nhật ListUId cho Card thành công." });
        }

        [HttpPut("{CardUId}/update-status")]
        public async Task<IActionResult> UpdateSatus(string CardUId, [FromQuery] string newStatus, [FromQuery] string userUId)
        {
            var card = _cardService.GetById(CardUId);
            if (card == null)
                return NotFound("Card không tồn tại");

            var success = await _cardService.UpdateStatus(CardUId, newStatus, userUId);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật status cho Card hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId,
                $"updated status of card '{card.Title}' to '{newStatus}'");
            return Ok(new { message = "Cập nhật status cho Card thành công." });
        }

        [HttpPut("{cardUId}/duedate")]
        public async Task<IActionResult> UpdateDueDate(string cardUId, [FromBody] UpdateDueDateRequest request)
        {
            var card = _cardService.GetById(cardUId);
            if (card == null)
                return NotFound("Card không tồn tại");

            var success = await _cardService.UpdateDueDateAsync(cardUId, request.DueDate, request.UserUId);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật ngày đến hạn cho Card hoặc bạn không có quyền." });

            string dateStr = request.DueDate?.ToString("yyyy-MM-dd") ?? "none";
            _ = _activity.AddActivity(request.UserUId, $"updated due date of card '{card.Title}' to '{dateStr}'");

            return Ok(new { message = "Cập nhật ngày đến hạn thành công." });
        }

        [HttpGet("{cardUId}/attachments")]
        public async Task<IActionResult> GetAttachments(string cardUId)
        {
            var attachments = await _cardService.GetAttachmentsByCardAsync(cardUId);
            return Ok(attachments);
        }

        [HttpDelete("{cardUId}/attachments/{fileUId}")]
        public async Task<IActionResult> DeleteAttachment(string cardUId, string fileUId, [FromQuery] string userUId)
        {
            var success = await _cardService.DeleteAttachmentAsync(fileUId, userUId);
            if (!success) return NotFound("Không tìm thấy tệp đính kèm hoặc bạn không có quyền.");
            _ = _activity.AddActivity(userUId, $"deleted attachment '{fileUId}' from card '{cardUId}'");
            return Ok(new { message = "Đã xóa tệp đính kèm." });
        }

        [HttpPut("{cardUId}/attachments/{fileUId}/description")]
        public async Task<IActionResult> UpdateAttachmentDescription(string cardUId, string fileUId, [FromQuery] string userUId, [FromQuery] string? description)
        {
            var success = await _cardService.UpdateAttachmentDescriptionAsync(fileUId, userUId, description);
            if (!success) return NotFound("Không tìm thấy tệp đính kèm hoặc bạn không có quyền.");
            _ = _activity.AddActivity(userUId, $"updated description for attachment '{fileUId}' in card '{cardUId}'");
            return Ok(new { message = "Đã cập nhật mô tả tệp đính kèm." });
        }

        public class AddFileRequest
        {
            public string Url { get; set; } = string.Empty;
            public string FileName { get; set; } = string.Empty;
            public string? Description { get; set; }
        }

        [HttpPost("{cardUId}/add-file")]
        public async Task<IActionResult> AddFileToCard(string cardUId, [FromBody] AddFileRequest request, [FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(request.Url) || string.IsNullOrEmpty(request.FileName))
                return BadRequest("File URL và FileName không được trống.");

            var (fileUrl, isDuplicate) = await _cardService.AddFileToCardAsync(cardUId, request.Url, request.FileName, userUId, request.Description);

            if (isDuplicate) return Conflict(new { message = "Tệp này đã được đính kèm trước đó." });
            if (fileUrl != null)
            {
                _ = _activity.AddActivity(userUId, $"added file '{request.FileName}' to card '{cardUId}'");
                return Ok(fileUrl);
            }

            return NotFound("Không tìm thấy card hoặc bạn không có quyền.");
        }

        [HttpPost("{cardUId}/attachments")]
        public async Task<IActionResult> UploadAttachment(string cardUId, IFormFile file, [FromQuery] string userUId, [FromForm] string? description = null)
        {
            if (file == null || file.Length == 0)
                return BadRequest("File không hợp lệ hoặc rỗng.");

            // 1. Upload to Cloudinary
            var uploadResult = await _cloudinaryService.UploadFileAsync(file);
            if (uploadResult == null)
                return StatusCode(500, "Lỗi khi upload file lên Cloudinary.");

            // 2. Save file URL to database
            var (fileUrl, isDuplicate) = await _cardService.AddFileToCardAsync(cardUId, uploadResult.Value.Url, uploadResult.Value.FileName, userUId, description);

            if (isDuplicate) return Conflict(new { message = "Tệp này đã được đính kèm trước đó." });
            if (fileUrl != null)
            {
                _ = _activity.AddActivity(userUId, $"attached file '{uploadResult.Value.FileName}' to card '{cardUId}'");
                return Ok(fileUrl);
            }

            return NotFound("Không tìm thấy card hoặc có lỗi xảy ra khi lưu trữ thông tin file.");
        }
        
        [HttpPost("{uid}/upload-background")]
        public async Task<IActionResult> UploadBackground(string uid, IFormFile file, [FromQuery] string userUId)
        {
            var card = _cardService.GetById(uid);
            if (card == null) return NotFound(new { message = "Card không tồn tại." });

            var result = await _cloudinaryService.UploadFileAsync(file);
            if (result == null) return BadRequest("Lỗi khi tải ảnh lên Cloudinary.");

            // Update card with new background URL directly
            card.BackgroundUrl = result.Value.Url;
            
            if (await _cardService.UpdateCard(card, userUId))
            {
                _ = _activity.AddActivity(userUId, $"updated background of card '{card.Title}'");
                return Ok(new { url = result.Value.Url });
            }
            
            return StatusCode(403, new { message = "Bạn không có quyền thay đổi ảnh nền card này." });
        }
    }
}
