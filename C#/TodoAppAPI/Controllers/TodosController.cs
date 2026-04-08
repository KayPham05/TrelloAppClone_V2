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
        public TodosController(ICardsService todosService, IActivity activity)
        {
            _cardService = todosService;
            _activity = activity;
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
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<TodosController>
        [HttpPost]
        public IActionResult Add(Card card)
        {
            if (_cardService.AddCard(card))
            {
                _ = _activity.AddActivity(" ", $"added card '{card.Title}' to list '{card.ListUId}'");
                return Ok("Thêm card thành công");
            }
                
            return BadRequest("Không thể thêm card");

        }

        [HttpPost("{userUId}/inbox")]
        public async Task<IActionResult> AddCardToInbox(string userUId, [FromBody] Card card)
        {
            if (card == null || string.IsNullOrEmpty(card.Title))
                return BadRequest("Thiếu thông tin card.");

            var createdCard = await _cardService.AddCardToInboxAsync(userUId, card);
            
            if (createdCard != null)
            {
                _ = _activity.AddActivity(userUId, $"added card '{createdCard.Title}' to inbox");
                return Ok(createdCard);
            }
                
            return StatusCode(500, "Không thể thêm card vào inbox");
        }

        // PUT api/<TodosController>/5
        [HttpPut("{id}")]
        public IActionResult Update(string id, [FromBody] Card card)
        {
            card.CardUId = id;
            if (_cardService.UpdateCard(card))
            {
                _ = _activity.AddActivity(" ", $"updated card '{card.Title}' in list '{card.ListUId}'");
                return Ok("Cập nhật card thành công");
            }
                
            return NotFound("Card không tồn tại");
        }

        // DELETE api/<TodosController>/5
        [HttpDelete("{id}")]
        public IActionResult Delete(string id)
        {
            var card = _cardService.GetById(id);
            if (card == null)
                return NotFound("Card không tồn tại");

            var cardName = card.Title;

            if (_cardService.DeleteCard(id))
            {
                _ = _activity.AddActivity(" ", $"deleted a card with id '{cardName}'");
                return Ok("Xóa card thành công");
            }
                
            return NotFound("Card không tồn tại");
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
        public async Task<IActionResult> UpdateSatus(string CardUId, [FromQuery] string newStatus)
        {
            var card = _cardService.GetById(CardUId);
            if (card == null)
                return NotFound("Card không tồn tại");

            var success = await _cardService.UpdateStatus(CardUId,  newStatus);
            if (!success)
                return BadRequest(new { message = "Không thể cập nhật status cho Card." });
            _ = _activity.AddActivity(" ",
                $"updated status of card '{card.Title}' to '{newStatus}'");
            return Ok(new { message = "Cập nhật status cho Card thành công." });
        }

        public class AddFileRequest
        {
            public string Url { get; set; } = string.Empty;
            public string FileName { get; set; } = string.Empty;
        }

        [HttpPost("{cardUId}/add-file")]
        public async Task<IActionResult> AddFileToCard(string cardUId, [FromBody] AddFileRequest request)
        {
            if (string.IsNullOrEmpty(request.Url) || string.IsNullOrEmpty(request.FileName))
                return BadRequest("File URL và FileName không được trống.");

            var fileUrl = await _cardService.AddFileToCardAsync(cardUId, request.Url, request.FileName);

            if (fileUrl != null)
            {
                _ = _activity.AddActivity(" ", $"added file '{request.FileName}' to card '{cardUId}'");
                return Ok(fileUrl);
            }

            return NotFound("Không tìm thấy card hoặc có lỗi xảy ra.");
        }
    }
}
