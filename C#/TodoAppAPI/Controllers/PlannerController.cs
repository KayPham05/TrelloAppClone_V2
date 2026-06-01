using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/planner")]
    [ApiController]
    [Authorize]
    public class PlannerController : ControllerBase
    {
        private readonly IPlannerService _plannerService;

        public PlannerController(IPlannerService plannerService)
        {
            _plannerService = plannerService;
        }

        /// <summary>
        /// Retrieves cards with due dates within the specified range for the current user, grouped by date.
        /// </summary>
        /// <param name="from">Start date (e.g. 2026-04-01)</param>
        /// <param name="to">End date (e.g. 2026-04-30)</param>
        /// <returns>A dictionary where keys are dates and values are lists of cards.</returns>
        [HttpGet("calendar")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetCalendarCards([FromQuery] DateTime from, [FromQuery] DateTime to)
        {
            if (from > to)
            {
                return BadRequest(new { message = "The 'from' date cannot be after the 'to' date." });
            }

            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrEmpty(userUId))
            {
                return Unauthorized(new { message = "User is not authenticated." });
            }

            var result = await _plannerService.GetPlannerCardsAsync(userUId, from, to);
            return Ok(result);
        }
    }
}
