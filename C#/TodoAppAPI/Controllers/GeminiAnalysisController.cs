using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
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
            [FromQuery] bool forceRefresh = false,
            CancellationToken cancellationToken = default)
        {
            var userUId = GetRequesterUId();
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });

            return ToActionResult(await _analysisService.AnalyzeWorkspaceAsync(workspaceUId, userUId, forceRefresh, cancellationToken));
        }

        [HttpGet("board/{boardUId}")]
        public async Task<IActionResult> AnalyzeBoard(
            string boardUId,
            [FromQuery] bool forceRefresh = false,
            CancellationToken cancellationToken = default)
        {
            var userUId = GetRequesterUId();
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });

            return ToActionResult(await _analysisService.AnalyzeBoardAsync(boardUId, userUId, forceRefresh, cancellationToken));
        }

        [HttpGet("card/{cardUId}")]
        public async Task<IActionResult> AnalyzeCard(
            string cardUId,
            [FromQuery] bool forceRefresh = false,
            CancellationToken cancellationToken = default)
        {
            var userUId = GetRequesterUId();
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });

            return ToActionResult(await _analysisService.AnalyzeCardAsync(cardUId, userUId, forceRefresh, cancellationToken));
        }

        [HttpGet("history/{scopeType}/{scopeUId}")]
        public async Task<IActionResult> GetReportHistory(
            string scopeType,
            string scopeUId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            CancellationToken cancellationToken = default)
        {
            var userUId = GetRequesterUId();
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });
            if (!IsSupportedScope(scopeType))
                return BadRequest(new { message = "scopeType must be workspace, board, or card" });

            page = Math.Max(1, page);
            pageSize = Math.Clamp(pageSize, 1, 20);

            return ToHistoryActionResult(await _analysisService.GetReportHistoryAsync(
                scopeType,
                scopeUId,
                userUId,
                page,
                pageSize,
                cancellationToken));
        }

        [HttpPost("report/save/{scopeType}/{scopeUId}")]
        public async Task<IActionResult> SaveLatestReport(
            string scopeType,
            string scopeUId,
            CancellationToken cancellationToken = default)
        {
            var userUId = GetRequesterUId();
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });
            if (!IsSupportedScope(scopeType))
                return BadRequest(new { message = "Unsupported analysis scope." });

            return ToSaveActionResult(await _analysisService.SaveLatestReportAsync(
                scopeType,
                scopeUId,
                userUId,
                cancellationToken));
        }

        [HttpGet("report/{reportUId}")]
        public async Task<IActionResult> GetReportById(
            string reportUId,
            CancellationToken cancellationToken = default)
        {
            var userUId = GetRequesterUId();
            if (string.IsNullOrWhiteSpace(userUId))
                return Unauthorized(new { message = "UserUId claim is required" });

            return ToActionResult(await _analysisService.GetReportByIdAsync(reportUId, userUId, cancellationToken));
        }

        private IActionResult ToActionResult(AnalysisResult result)
        {
            return result.Status switch
            {
                AnalysisResultStatus.Success => Ok(result.Analysis),
                AnalysisResultStatus.NotFound => NotFound(new { message = result.Message }),
                AnalysisResultStatus.Forbidden => StatusCode(403, new { message = result.Message }),
                AnalysisResultStatus.BadRequest => BadRequest(new { message = result.Message }),
                _ => StatusCode(500, new { message = "Unexpected analysis result." })
            };
        }

        private IActionResult ToHistoryActionResult(AnalysisReportHistoryResult result)
        {
            return result.Status switch
            {
                AnalysisResultStatus.Success => Ok(result.Page),
                AnalysisResultStatus.NotFound => NotFound(new { message = result.Message }),
                AnalysisResultStatus.Forbidden => StatusCode(403, new { message = result.Message }),
                _ => StatusCode(500, new { message = "Unexpected analysis history result." })
            };
        }

        private IActionResult ToSaveActionResult(AnalysisReportSaveResult result)
        {
            return result.Status switch
            {
                AnalysisResultStatus.Success => Ok(result.Report),
                AnalysisResultStatus.NotFound => NotFound(new { message = result.Message }),
                AnalysisResultStatus.Forbidden => StatusCode(403, new { message = result.Message }),
                AnalysisResultStatus.BadRequest => BadRequest(new { message = result.Message }),
                _ => StatusCode(500, new { message = "Unexpected analysis save result." })
            };
        }

        private string? GetRequesterUId()
        {
            return HttpContext?.User?.FindFirstValue("UserUId");
        }

        private static bool IsSupportedScope(string scopeType)
        {
            return scopeType is "workspace" or "board" or "card";
        }
    }
}
