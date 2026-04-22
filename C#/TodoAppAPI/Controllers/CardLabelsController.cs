using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/cards/{cardId}/labels")]
    [ApiController]
    public class CardLabelsController : ControllerBase
    {
        private readonly ICardLabelService _cardLabelService;

        public CardLabelsController(ICardLabelService cardLabelService)
        {
            _cardLabelService = cardLabelService;
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
