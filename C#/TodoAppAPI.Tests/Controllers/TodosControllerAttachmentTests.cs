using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Moq;
using TodoAppAPI.Controllers;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using Xunit;

namespace TodoAppAPI.Tests.Controllers;

public class TodosControllerAttachmentTests
{
    private readonly Mock<ICardsService> _cardService = new();
    private readonly Mock<IActivity> _activity = new();

    [Fact]
    public async Task UpdateAttachmentName_should_return_bad_request_when_file_name_is_blank()
    {
        var controller = CreateController();

        var result = await controller.UpdateAttachmentName("card-1", "file-1", "user-1", " ");

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Equal("Tên tệp không được để trống.", badRequest.Value);
        _cardService.Verify(
            service => service.UpdateAttachmentNameAsync(
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string>()),
            Times.Never);
    }

    [Fact]
    public async Task UpdateAttachmentName_should_return_not_found_when_service_returns_false()
    {
        _cardService
            .Setup(service => service.UpdateAttachmentNameAsync("file-1", "user-1", "new.pdf"))
            .ReturnsAsync(false);
        var controller = CreateController();

        var result = await controller.UpdateAttachmentName("card-1", "file-1", "user-1", "new.pdf");

        Assert.IsType<NotFoundObjectResult>(result);
    }

    [Fact]
    public async Task UpdateAttachmentName_should_return_ok_and_log_activity_when_service_succeeds()
    {
        _cardService
            .Setup(service => service.UpdateAttachmentNameAsync("file-1", "user-1", "new.pdf"))
            .ReturnsAsync(true);
        _activity
            .Setup(activity => activity.AddActivity("user-1", It.IsAny<string>()))
            .ReturnsAsync(true);
        var controller = CreateController();

        var result = await controller.UpdateAttachmentName("card-1", "file-1", "user-1", "new.pdf");

        Assert.IsType<OkObjectResult>(result);
        _activity.Verify(
            activity => activity.AddActivity(
                "user-1",
                It.Is<string>(value => value.Contains("file-1") && value.Contains("card-1"))),
            Times.Once);
    }

    private TodosController CreateController()
    {
        return new TodosController(
            _cardService.Object,
            _activity.Object,
            new Mock<ICloudinaryService>().Object,
            new Mock<IUserInboxCard>().Object,
            new Mock<IHubContext<BoardHub>>().Object,
            new Mock<IHubContext<NotificationHub>>().Object,
            new Mock<IListService>().Object);
    }
}
