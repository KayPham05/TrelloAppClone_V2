using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/Activity")]
    [ApiController]
    [Authorize]
    public class ActivityController : ControllerBase
    {
        private readonly IActivity _activityService;
         public ActivityController(IActivity activityService)
         {
              _activityService = activityService;
         }

        [HttpGet]
        public async Task<IActionResult> GetActivities([FromQuery] int limit = 10, [FromQuery] int offset = 0)
        {
            if (limit > 50) limit = 50;
            if (limit < 1) limit = 10;
            if (offset < 0) offset = 0;

            var activities = await _activityService.GetActivities(limit, offset);

            // Get total count for frontend
            var totalCount = await _activityService.GetTotalCount();

            return Ok(new
            {
                data = activities,
                pagination = new
                {
                    limit,
                    offset,
                    total = totalCount,
                    hasMore = (offset + limit) < totalCount
                }
            });
        }

        [HttpGet("user/{userUId}")]
        public async Task<IActionResult> GetActivitiesByUser(string userUId, [FromQuery] int limit = 50)
        {
            var activities = await _activityService.GetActivitiesByUserUId(userUId, limit);
            return Ok(activities);
        }

    }
}
