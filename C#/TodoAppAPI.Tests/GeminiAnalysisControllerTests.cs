using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;
using TodoAppAPI.Controllers;
using TodoAppAPI.DTOs.ProjectAnalysis;
using TodoAppAPI.Interfaces;
using Xunit;

namespace TodoAppAPI.Tests;

public class GeminiAnalysisControllerTests
{
    [Fact]
    public async Task AnalyzeBoard_returns_unauthorized_when_jwt_user_id_is_missing()
    {
        var service = new Mock<IGeminiAnalysisService>();
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.AnalyzeBoard("board-1", false, CancellationToken.None);

        Assert.IsType<UnauthorizedObjectResult>(result);
        service.Verify(
            s => s.AnalyzeBoardAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<bool>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task AnalyzeBoard_returns_forbidden_for_viewer_or_unauthorized_user()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.AnalyzeBoardAsync("board-1", "viewer", false, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.Forbidden("forbidden"));
        var controller = CreateController(service.Object, "viewer");

        var result = await controller.AnalyzeBoard("board-1", false, CancellationToken.None);

        var objectResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(403, objectResult.StatusCode);
    }

    [Fact]
    public async Task AnalyzeBoard_returns_not_found_for_missing_board()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.AnalyzeBoardAsync("missing", "admin", false, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.NotFound("missing"));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.AnalyzeBoard("missing", false, CancellationToken.None);

        Assert.IsType<NotFoundObjectResult>(result);
    }

    [Fact]
    public async Task AnalyzeBoard_returns_ok_for_successful_report()
    {
        var report = new ProjectAnalysisDto
        {
            ScopeType = "board",
            ScopeUId = "board-1",
            Title = "Sprint Board",
            Summary = "Report ready"
        };
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.AnalyzeBoardAsync("board-1", "admin", true, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.Success(report));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.AnalyzeBoard("board-1", true, CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Same(report, ok.Value);
    }

    [Fact]
    public async Task AnalyzeBoard_uses_jwt_user_id_instead_of_query_user_id()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.AnalyzeBoardAsync("board-1", "jwt-user", false, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.Success(new ProjectAnalysisDto()));
        var controller = CreateController(service.Object, "jwt-user");

        await controller.AnalyzeBoard("board-1", false, CancellationToken.None);

        service.Verify(
            s => s.AnalyzeBoardAsync("board-1", "jwt-user", false, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task GetReportHistory_returns_unauthorized_when_jwt_user_id_missing()
    {
        var service = new Mock<IGeminiAnalysisService>();
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.GetReportHistory("board", "board-1", 1, 10, CancellationToken.None);

        Assert.IsType<UnauthorizedObjectResult>(result);
        service.Verify(
            s => s.GetReportHistoryAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<int>(), It.IsAny<int>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task SaveLatestReport_returns_unauthorized_when_jwt_user_id_missing()
    {
        var service = new Mock<IGeminiAnalysisService>();
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.SaveLatestReport("board", "board-1", CancellationToken.None);

        Assert.IsType<UnauthorizedObjectResult>(result);
        service.Verify(
            s => s.SaveLatestReportAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task SaveLatestReport_returns_ok_for_saved_report()
    {
        var report = new AnalysisReportSummaryDto
        {
            ReportUId = "report-1",
            ScopeType = "board",
            ScopeUId = "board-1",
            Title = "Board",
            OverallProgress = 64,
            ModelUsed = "gemini-test",
            GeneratedAt = DateTime.UtcNow
        };
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.SaveLatestReportAsync("board", "board-1", "admin", It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisReportSaveResult.Success(report));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.SaveLatestReport("board", "board-1", CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Same(report, ok.Value);
    }

    [Fact]
    public async Task SaveLatestReport_returns_bad_request_for_unsaveable_report()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.SaveLatestReportAsync("board", "board-1", "admin", It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisReportSaveResult.BadRequest("Chỉ có thể lưu báo cáo Gemini thành công."));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.SaveLatestReport("board", "board-1", CancellationToken.None);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.NotNull(badRequest.Value);
    }

    [Fact]
    public async Task GetReportHistory_clamps_invalid_paging()
    {
        var page = new AnalysisReportHistoryPageDto();
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.GetReportHistoryAsync("board", "board-1", "admin", 1, 20, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisReportHistoryResult.Success(page));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.GetReportHistory("board", "board-1", -5, 100, CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Same(page, ok.Value);
    }

    [Fact]
    public async Task GetReportHistory_returns_forbidden_for_unauthorized_user()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.GetReportHistoryAsync("board", "board-1", "viewer", 1, 10, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisReportHistoryResult.Forbidden("forbidden"));
        var controller = CreateController(service.Object, "viewer");

        var result = await controller.GetReportHistory("board", "board-1", 1, 10, CancellationToken.None);

        var objectResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(403, objectResult.StatusCode);
    }

    [Fact]
    public async Task GetReportById_returns_ok_for_saved_report()
    {
        var report = new ProjectAnalysisDto { ScopeType = "board", ScopeUId = "board-1" };
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.GetReportByIdAsync("report-1", "admin", It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.Success(report));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.GetReportById("report-1", CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Same(report, ok.Value);
    }

    [Fact]
    public async Task GetReportById_returns_not_found_for_missing_report()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.GetReportByIdAsync("missing", "admin", It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.NotFound("missing"));
        var controller = CreateController(service.Object, "admin");

        var result = await controller.GetReportById("missing", CancellationToken.None);

        Assert.IsType<NotFoundObjectResult>(result);
    }

    private static GeminiAnalysisController CreateController(IGeminiAnalysisService service, string userUId)
    {
        return new GeminiAnalysisController(service)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = new ClaimsPrincipal(new ClaimsIdentity(
                        [new Claim("UserUId", userUId)],
                        "TestAuth"))
                }
            }
        };
    }
}
