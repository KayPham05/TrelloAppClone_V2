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
    public async Task AnalyzeBoard_returns_bad_request_when_user_id_is_missing()
    {
        var service = new Mock<IGeminiAnalysisService>();
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.AnalyzeBoard("board-1", "", false, CancellationToken.None);

        Assert.IsType<BadRequestObjectResult>(result);
        service.Verify(
            s => s.AnalyzeBoardAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<bool>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task AnalyzeBoard_returns_forbidden_for_viewer_or_unauthorized_user()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.AnalyzeBoardAsync("board-1", "viewer", false, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.Forbidden("Bạn không có quyền phân tích board này."));
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.AnalyzeBoard("board-1", "viewer", false, CancellationToken.None);

        Assert.IsType<ObjectResult>(result);
        Assert.Equal(403, ((ObjectResult)result).StatusCode);
    }

    [Fact]
    public async Task AnalyzeBoard_returns_not_found_for_missing_board()
    {
        var service = new Mock<IGeminiAnalysisService>();
        service.Setup(s => s.AnalyzeBoardAsync("missing", "admin", false, It.IsAny<CancellationToken>()))
            .ReturnsAsync(AnalysisResult.NotFound("Không tìm thấy board."));
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.AnalyzeBoard("missing", "admin", false, CancellationToken.None);

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
        var controller = new GeminiAnalysisController(service.Object);

        var result = await controller.AnalyzeBoard("board-1", "admin", true, CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Same(report, ok.Value);
    }
}
