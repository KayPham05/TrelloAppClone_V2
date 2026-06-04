using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs.ProjectAnalysis;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/analysis")]
    [ApiController]
    [Authorize]
    public class GeminiAnalysisController : ControllerBase
    {
        private readonly IGeminiAnalysisService _analysisService;

        public GeminiAnalysisController(IGeminiAnalysisService analysisService)
        {
            _analysisService = analysisService;
        }

        [HttpGet("workspace/{workspaceUId}")]
        public async Task<IActionResult> AnalyzeWorkspace(
            string workspaceUId,
            [FromQuery] string userUId,
            [FromQuery] bool forceRefresh = false,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest(new { message = "userUId is required" });

            return ToActionResult(await _analysisService.AnalyzeWorkspaceAsync(workspaceUId, userUId, forceRefresh, cancellationToken));
        }

        [HttpGet("board/{boardUId}")]
        public async Task<IActionResult> AnalyzeBoard(
            string boardUId,
            [FromQuery] string userUId,
            [FromQuery] bool forceRefresh = false,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest(new { message = "userUId is required" });

            return ToActionResult(await _analysisService.AnalyzeBoardAsync(boardUId, userUId, forceRefresh, cancellationToken));
        }

        [HttpGet("card/{cardUId}")]
        public async Task<IActionResult> AnalyzeCard(
            string cardUId,
            [FromQuery] string userUId,
            [FromQuery] bool forceRefresh = false,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(userUId))
                return BadRequest(new { message = "userUId is required" });

            return ToActionResult(await _analysisService.AnalyzeCardAsync(cardUId, userUId, forceRefresh, cancellationToken));
        }

        private IActionResult ToActionResult(AnalysisResult result)
        {
            return result.Status switch
            {
                AnalysisResultStatus.Success => Ok(result.Analysis),
                AnalysisResultStatus.NotFound => NotFound(new { message = result.Message }),
                AnalysisResultStatus.Forbidden => StatusCode(403, new { message = result.Message }),
                _ => StatusCode(500, new { message = "Unexpected analysis result." })
            };
        }
    }
}
