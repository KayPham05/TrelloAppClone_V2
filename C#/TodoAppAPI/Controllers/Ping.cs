using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/ping")]
    [ApiController]
    [Authorize]
    public class Ping : ControllerBase
    {
        // GET: api/<Ping>
        [HttpGet]
        public IActionResult PingAlive() => Ok("Alive");

    }
}
