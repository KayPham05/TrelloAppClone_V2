using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/search")]
    [ApiController]
    [Authorize]
    public class SearchController : ControllerBase
    {
        private readonly ISearchService _searchService;

        public SearchController(ISearchService searchService)
        {
            _searchService = searchService;
        }

        [HttpGet]
        public async Task<IActionResult> Search([FromQuery] string q, [FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
            {
                return BadRequest(new { message = "userUId is required" });
            }

            if (string.IsNullOrWhiteSpace(q))
            {
                return Ok(new { Boards = new object[] { }, Cards = new object[] { } });
            }

            var result = await _searchService.SearchBoardsAndCardsAsync(q, userUId);
            return Ok(result);
        }
    }
}
