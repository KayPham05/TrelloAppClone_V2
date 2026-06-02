using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Hubs;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/cards/{cardId}/labels")]
    [ApiController]
    public class CardLabelsController : ControllerBase
    {
        private readonly ICardLabelService _cardLabelService;
        private readonly IHubContext<BoardHub> _boardHubContext;
        private readonly ICardsService _cardService;
        private readonly IListService _listService;

        public CardLabelsController(ICardLabelService cardLabelService, IHubContext<BoardHub> boardHubContext, ICardsService cardService, IListService listService)
        {
            _cardLabelService = cardLabelService;
            _boardHubContext = boardHubContext;
            _cardService = cardService;
            _listService = listService;
        }

        [HttpPost]
        public async Task<IActionResult> AddLabel(string cardId, [FromBody] CreateCardLabelRequest request)
        {
            request.Title ??= "";
            if (string.IsNullOrEmpty(cardId) || string.IsNullOrEmpty(request.ColorCode))
            {
                return BadRequest("Thiếu thông tin.");
            }

            var label = await _cardLabelService.AddLabelAsync(cardId, request);

            var card = _cardService.GetById(cardId);
            if (card != null && !string.IsNullOrEmpty(card.ListUId))
            {
                var list = await _listService.GetListByIdAsync(card.ListUId);
                if (list != null)
                {
                    await _boardHubContext.Clients.Group(BoardHub.BoardGroup(list.BoardUId))
                        .SendAsync("CardLabelAdded", new { cardId, label, boardUId = list.BoardUId });
                }
            }

            return Ok(label);
        }

        [HttpPut("{labelId}")]
        public async Task<IActionResult> UpdateLabel(string labelId, [FromBody] UpdateCardLabelRequest request)
        {
            request.Title ??= "";
            if (string.IsNullOrEmpty(labelId) || string.IsNullOrEmpty(request.ColorCode))
            {
                return BadRequest("Thiếu thông tin.");
            }

            var success = await _cardLabelService.UpdateLabelAsync(labelId, request);
            if (!success)
            {
                return NotFound("Không tìm thấy nhãn.");
            }

            // Need boardUId for realtime. CardLabel might not have it directly. 
            // In a real app we'd fetch the boardId associated with this label.
            // For now, if cardId is not passed in payload, we might have a limitation.
            // Assuming we need cardId to find boardId.
            
            return Ok(new { message = "Cập nhật nhãn thành công." });
        }

        [HttpDelete("{labelId}")]
        public async Task<IActionResult> DeleteLabel(string labelId)
        {
            var success = await _cardLabelService.DeleteLabelAsync(labelId);
            if (!success)
            {
                return NotFound("Không tìm thấy nhãn.");
            }

            return Ok(new { message = "Xóa nhãn thành công." });
        }
    }
}
