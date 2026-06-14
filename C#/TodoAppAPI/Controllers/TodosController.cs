using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using TodoAppAPI.Constants;
using TodoAppAPI.Hubs;
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
        private const string CardNotFoundMessage = "Card không tồn tại";
        private const string CardNotFoundOrNoPermissionMessage = "Card không tồn tại hoặc bạn không có quyền";
        private const string CardUpdatedEvent = "CardUpdated";

        private readonly ICardsService _cardService;
        private readonly IActivity _activity;
        private readonly ICloudinaryService _cloudinaryService;
        private readonly IUserInboxCard _userInboxCardService;
        private readonly IHubContext<BoardHub> _boardHubContext;
        private readonly IHubContext<NotificationHub> _notificationHubContext;
        private readonly IListService _listService;

        public TodosController(ICardsService todosService, IActivity activity, ICloudinaryService cloudinaryService, IUserInboxCard userInboxCardService, IHubContext<BoardHub> boardHubContext, IHubContext<NotificationHub> notificationHubContext, IListService listService)
        {
            _cardService = todosService;
            _activity = activity;
            _cloudinaryService = cloudinaryService;
            _userInboxCardService = userInboxCardService;
            _boardHubContext = boardHubContext;
            _notificationHubContext = notificationHubContext;
            _listService = listService;
        }

        // GET: api/<TodosController>
        [HttpGet("by-board/{boardUId}")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<Card>))]
        public IActionResult GetByBoard(string boardUId)
        {
            var cards = _cardService.GetCardsByBoardId(boardUId);
            return Ok(cards);
        }

        [HttpPost("by-board/{boardUId}/filter")]
        public async Task<IActionResult> FilterByBoard(string boardUId, [FromBody] BoardCardFilterRequest? request)
        {
            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });

            var result = await _cardService.FilterCardsByBoardAsync(
                boardUId,
                request ?? new BoardCardFilterRequest(),
                userUId);

            return result.Status switch
            {
                BoardCardFilterResultStatus.Success => Ok(result.Cards),
                BoardCardFilterResultStatus.BadRequest => BadRequest(new { message = result.Message }),
                BoardCardFilterResultStatus.Forbidden => StatusCode(403, new { message = result.Message }),
                BoardCardFilterResultStatus.NotFound => NotFound(new { message = result.Message }),
                _ => StatusCode(500, new { message = "KhÃ´ng thá»ƒ lá»c card." })
            };
        }

        // GET api/<TodosController>/5
        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(Card))]
        public IActionResult Get(string id)
        {
            var card = _cardService.GetById(id);
            if (card == null) return NotFound(CardNotFoundMessage);
            return Ok(card);
        }

        // POST api/<TodosController>
        [HttpPost]
        public async Task<IActionResult> Add([FromBody] Card card)
        {
            if (CardStatusValues.IsDueDateInPast(card.DueDate))
                return BadRequest(new { message = CardStatusValues.DueDateInPastMessage });

            if (await _cardService.AddCard(card))
            {
                _ = _activity.AddActivity(card.UserUId, $"added card '{card.Title}' to list '{card.ListUId}'");
                if (!string.IsNullOrEmpty(card.ListUId))
                {
                    var list = await _listService.GetListByIdAsync(card.ListUId);
                    if (list != null)
                    {
                        await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId)).SendAsync("CardAdded", card);
                        
                        await _notificationHubContext.Clients.Group($"Board_{list.BoardUId}")
                            .SendAsync("CardAdded", card);
                    }
                }

                // Gửi thông báo cho Planner của chính người tạo
                await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(card.UserUId))
                    .SendAsync("CardAdded", card);

                return Ok(card);
            }
                
            return BadRequest(new { message = "Không thể thêm card hoặc bạn không có quyền" });
        }

        [HttpPost("{userUId}/inbox")]
        public async Task<IActionResult> AddCardToInbox(string userUId, [FromBody] Card card)
        {
            if (card == null || string.IsNullOrEmpty(card.Title))
                return BadRequest("Thiếu thông tin card.");

            if (CardStatusValues.IsDueDateInPast(card.DueDate))
                return BadRequest(new { message = CardStatusValues.DueDateInPastMessage });

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
            if (CardStatusValues.IsDueDateInPast(card.DueDate))
                return BadRequest(new { message = CardStatusValues.DueDateInPastMessage });

            card.CardUId = id;
            if (await _cardService.UpdateCard(card, userUId))
            {
                _ = _activity.AddActivity(userUId, $"updated card '{card.Title}' in list '{card.ListUId}'");
                var existingCard = _cardService.GetById(id);
                if (existingCard != null && !string.IsNullOrEmpty(existingCard.ListUId))
                {
                    var list = await _listService.GetListByIdAsync(existingCard.ListUId);
                    if (list != null)
                    {
                        await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId)).SendAsync(CardUpdatedEvent, existingCard);
                        
                        await _notificationHubContext.Clients.Group($"Board_{list.BoardUId}")
                            .SendAsync(CardUpdatedEvent, existingCard);
                    }
                }

                // Thông báo cho Planner
                await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                    .SendAsync(CardUpdatedEvent, existingCard);

                return Ok("Cập nhật card thành công");
            }
                
            return NotFound(CardNotFoundOrNoPermissionMessage);
        }

        [HttpPut("inbox/{id}")]
        public async Task<IActionResult> UpdateInbox(string id, [FromBody] Card card, [FromQuery] string userUId)
        {
            if (CardStatusValues.IsDueDateInPast(card.DueDate))
                return BadRequest(new { message = CardStatusValues.DueDateInPastMessage });

            if (await _userInboxCardService.UpdateInboxCardAsync(id, userUId, card))
            {
                _ = _activity.AddActivity(userUId, $"updated card '{card.Title}' in inbox");
                
                // Thông báo cho Planner
                await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                    .SendAsync(CardUpdatedEvent, card);

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
                return NotFound(CardNotFoundMessage);

            var cardName = card.Title;

            if (await _cardService.DeleteCard(id, userUId))
            {
                _ = _activity.AddActivity(userUId, $"deleted a card with id '{cardName}'");
                if (!string.IsNullOrEmpty(card.ListUId))
                {
                    var list = await _listService.GetListByIdAsync(card.ListUId);
                    if (list != null)
                    {
                        await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId)).SendAsync("CardDeleted", new { cardUId = id, boardUId = list.BoardUId });
                        
                        await _notificationHubContext.Clients.Group($"Board_{list.BoardUId}")
                            .SendAsync("CardDeleted", new { cardUId = id });
                    }
                }

                // Thông báo cho Planner
                await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                    .SendAsync("CardDeleted", new { cardUId = id });

                return Ok("Xóa card thành công");
            }
                
            return NotFound(CardNotFoundOrNoPermissionMessage);
        }

        [HttpGet("{id}/description")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(object))]
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
                return NotFound(CardNotFoundMessage);

            var success = await _cardService.UpdateListUid(CardUId, body.ListUId, body.UserUId, body.Position);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật ListUId cho Card." });

            _ = _activity.AddActivity(body.UserUId,
                $"moved card '{card.Title}' to another list");

            if (!string.IsNullOrEmpty(body.ListUId))
            {
                var list = await _listService.GetListByIdAsync(body.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CardMoved", new { cardUId = CardUId, newListUId = body.ListUId, position = body.Position, boardUId = list.BoardUId });
                        
                    await _notificationHubContext.Clients.Group($"Board_{list.BoardUId}")
                        .SendAsync("CardMoved", new { cardUId = CardUId, newListUId = body.ListUId, position = body.Position });
                }
            }

            // Thông báo cho Planner
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(body.UserUId))
                .SendAsync("CardMoved", new { cardUId = CardUId, newListUId = body.ListUId, position = body.Position });

            return Ok(new { message = "Cập nhật ListUId cho Card thành công." });
        }

        [HttpPut("{CardUId}/update-status")]
        public async Task<IActionResult> UpdateSatus(string CardUId, [FromQuery] string newStatus, [FromQuery] string userUId)
        {
            var card = _cardService.GetById(CardUId);
            if (card == null)
                return NotFound(CardNotFoundMessage);

            var updatedStatus = await _cardService.UpdateStatus(CardUId, newStatus, userUId);
            if (updatedStatus == null)
                return BadRequest(new { message = "Không thể cập nhật status cho Card hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId,
                $"updated status of card '{card.Title}' to '{updatedStatus}'");

            if (!string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CardStatusUpdated", new { cardUId = CardUId, newStatus = updatedStatus, boardUId = list.BoardUId });
                        
                    await _notificationHubContext.Clients.Group($"Board_{list.BoardUId}")
                        .SendAsync("CardStatusUpdated", new { cardUId = CardUId, newStatus = updatedStatus });
                }
            }

            // Thông báo cho Planner
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                .SendAsync("CardStatusUpdated", new { cardUId = CardUId, newStatus = updatedStatus });

            return Ok(new { message = "Cập nhật status cho Card thành công." });
        }

        [HttpPut("{cardUId}/duedate")]
        public async Task<IActionResult> UpdateDueDate(string cardUId, [FromBody] UpdateDueDateRequest request)
        {
            var card = _cardService.GetById(cardUId);
            if (card == null)
                return NotFound(CardNotFoundMessage);

            if (CardStatusValues.IsDueDateInPast(request.DueDate))
                return BadRequest(new { message = CardStatusValues.DueDateInPastMessage });

            var success = await _cardService.UpdateDueDateAsync(cardUId, request.DueDate, request.UserUId);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật ngày đến hạn cho Card hoặc bạn không có quyền." });

            string dateStr = request.DueDate?.ToString("yyyy-MM-dd") ?? "none";
            _ = _activity.AddActivity(request.UserUId, $"updated due date of card '{card.Title}' to '{dateStr}'");

            if (!string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    // Gửi cho BoardHub để cập nhật UI board
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CardDueDateUpdated", new { cardUId = cardUId, dueDate = request.DueDate, boardUId = list.BoardUId });
                    
                    // Gửi cho NotificationHub Group Board để cập nhật Planner cho tất cả thành viên trong board đó
                    await _notificationHubContext.Clients.Group($"Board_{list.BoardUId}")
                        .SendAsync("CardDueDateUpdated", new { cardUId = cardUId, dueDate = request.DueDate });
                }
            }

            // Gửi riêng cho chính user (để chắc chắn)
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(request.UserUId))
                .SendAsync("CardDueDateUpdated", new { cardUId = cardUId, dueDate = request.DueDate });

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

        [HttpPut("{cardUId}/attachments/{fileUId}/rename")]
        public async Task<IActionResult> UpdateAttachmentName(string cardUId, string fileUId, [FromQuery] string userUId, [FromQuery] string fileName)
        {
            if (string.IsNullOrWhiteSpace(fileName))
                return BadRequest("Tên tệp không được để trống.");

            var success = await _cardService.UpdateAttachmentNameAsync(fileUId, userUId, fileName);
            if (!success) return NotFound("Không tìm thấy tệp đính kèm hoặc bạn không có quyền.");
            _ = _activity.AddActivity(userUId, $"updated name for attachment '{fileUId}' in card '{cardUId}'");
            return Ok(new { message = "Đã cập nhật tên tệp đính kèm." });
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

        // PATCH v1/api/cards/{id}/archive
        [HttpPatch("{id}/archive")]
        public async Task<IActionResult> ArchiveCard(string id, [FromQuery] string userUId)
        {
            var success = await _cardService.ArchiveCardAsync(id, userUId);
            if (!success) return StatusCode(403, new { message = "Không thể lưu trữ thẻ hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId, $"archived card '{id}'");

            var card = _cardService.GetById(id);
            if (card != null && !string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CardArchived", new { cardUId = id, boardUId = list.BoardUId });
                }
            }

            // Thông báo cho Planner
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                .SendAsync("CardArchived", new { cardUId = id });

            return Ok(new { message = "Thẻ đã được lưu trữ." });
        }

        // PATCH v1/api/cards/{id}/unarchive
        [HttpPatch("{id}/unarchive")]
        public async Task<IActionResult> UnarchiveCard(string id, [FromQuery] string userUId)
        {
            var success = await _cardService.UnarchiveCardAsync(id, userUId);
            if (!success) return StatusCode(403, new { message = "Không thể khôi phục thẻ hoặc bạn không có quyền." });
            _ = _activity.AddActivity(userUId, $"unarchived card '{id}'");

            // Thông báo cho Planner
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                .SendAsync("CardUnarchived", new { cardUId = id });

            return Ok(new { message = "Thẻ đã được khôi phục." });
        }

        // GET v1/api/cards/archived?boardUId=&userUId=
        [HttpGet("archived")]
        public async Task<IActionResult> GetArchivedCards([FromQuery] string boardUId, [FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(boardUId)) return BadRequest("boardUId is required");
            var cards = await _cardService.GetArchivedCardsByBoardAsync(boardUId, userUId);
            return Ok(cards);
        }

        // POST v1/api/cards/{id}/join
        [HttpPost("{id}/join")]
        public async Task<IActionResult> JoinCard(string id, [FromQuery] string userUId, [FromQuery] string boardId)
        {
            if (string.IsNullOrEmpty(userUId) || string.IsNullOrEmpty(boardId))
                return BadRequest("userUId and boardId are required");
            var success = await _cardService.JoinCardAsync(id, userUId, boardId);
            if (!success) return StatusCode(403, new { message = "Không thể tham gia thẻ. Kiểm tra quyền hoặc cài đặt bảng." });
            _ = _activity.AddActivity(userUId, $"joined card '{id}'");
            return Ok(new { message = "Đã tham gia thẻ thành công." });
        }
    }
}
