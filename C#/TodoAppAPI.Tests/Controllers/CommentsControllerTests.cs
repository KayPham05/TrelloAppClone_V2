using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Moq;
using System.Security.Claims;
using TodoAppAPI.Controllers;
using TodoAppAPI.DTOs.Comments;
using TodoAppAPI.Hubs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using Xunit;

namespace TodoAppAPI.Tests.Controllers;

public class CommentsControllerTests
{
    private readonly Mock<ICommentService> _mockCommentService;
    private readonly Mock<IActivity> _mockActivity;
    private readonly Mock<IHubContext<BoardHub>> _mockHubContext;
    private readonly Mock<IClientProxy> _mockClientProxy;
    private readonly Mock<ICardsService> _mockCardService;
    private readonly Mock<IListService> _mockListService;
    private readonly Mock<ICloudinaryService> _mockCloudinaryService;
    private readonly CommentsController _controller;

    public CommentsControllerTests()
    {
        _mockCommentService = new Mock<ICommentService>();
        _mockActivity = new Mock<IActivity>();
        _mockHubContext = new Mock<IHubContext<BoardHub>>();
        _mockClientProxy = new Mock<IClientProxy>();
        _mockCardService = new Mock<ICardsService>();
        _mockListService = new Mock<IListService>();
        _mockCloudinaryService = new Mock<ICloudinaryService>();

        var mockClients = new Mock<IHubClients>();
        mockClients.Setup(c => c.Group(It.IsAny<string>())).Returns(_mockClientProxy.Object);
        _mockHubContext.Setup(h => h.Clients).Returns(mockClients.Object);

        _controller = new CommentsController(
            _mockCommentService.Object,
            _mockActivity.Object,
            _mockHubContext.Object,
            _mockCardService.Object,
            _mockListService.Object,
            _mockCloudinaryService.Object);

        var user = new ClaimsPrincipal(new ClaimsIdentity(new Claim[]
        {
            new Claim("UserUId", "u1"),
            new Claim("Email", "test@test.com")
        }, "mock"));

        _controller.ControllerContext = new ControllerContext()
        {
            HttpContext = new Microsoft.AspNetCore.Http.DefaultHttpContext() { User = user }
        };
    }

    [Fact]
    public async Task Add_returns_ok_with_comment_and_broadcasts()
    {
        var request = new CommentCreateRequest { CardUId = "c1", UserUId = "u1", Content = "Test" };
        var added = new Comment { CommentUId = "cm1", Content = "Test", CardUId = "c1", UserUId = "u1" };
        
        _mockCommentService.Setup(s => s.AddCommentAsync(It.IsAny<Comment>())).ReturnsAsync(added);
        _mockCardService.Setup(s => s.GetById("c1")).Returns(new Card { CardUId = "c1", ListUId = "l1" });
        _mockListService.Setup(s => s.GetListByIdAsync("l1")).ReturnsAsync(new List { ListUId = "l1", BoardUId = "b1" });

        var result = await _controller.Add(request);

        var okResult = Assert.IsType<OkObjectResult>(result);
        var returnedComment = Assert.IsType<CommentResponseDto>(okResult.Value);
        Assert.Equal("cm1", returnedComment.CommentUId);

        _mockClientProxy.Verify(c => c.SendCoreAsync("CommentAdded", It.IsAny<object[]>(), default), Times.Once);
    }

    [Fact]
    public async Task Update_returns_ok_and_broadcasts()
    {
        var request = new CommentUpdateRequest { UserUId = "u1", Content = "Updated" };
        var existing = new Comment { CommentUId = "cm1", CardUId = "c1", UserUId = "u1" };
        
        _mockCommentService.Setup(s => s.GetByIdAsync("cm1")).ReturnsAsync(existing);
        _mockCommentService.Setup(s => s.UpdateCommentAsync(It.IsAny<Comment>())).ReturnsAsync(true);
        _mockCardService.Setup(s => s.GetById("c1")).Returns(new Card { CardUId = "c1", ListUId = "l1" });
        _mockListService.Setup(s => s.GetListByIdAsync("l1")).ReturnsAsync(new List { ListUId = "l1", BoardUId = "b1" });

        var result = await _controller.Update("cm1", request);

        var okResult = Assert.IsType<OkObjectResult>(result);
        _mockClientProxy.Verify(c => c.SendCoreAsync("CommentUpdated", It.IsAny<object[]>(), default), Times.Once);
    }

    [Fact]
    public async Task Delete_returns_ok_and_broadcasts()
    {
        var existing = new Comment { CommentUId = "cm1", CardUId = "c1", UserUId = "u1" };
        
        _mockCommentService.Setup(s => s.GetByIdAsync("cm1")).ReturnsAsync(existing);
        _mockCommentService.Setup(s => s.DeleteCommentAsync("cm1")).ReturnsAsync(true);
        _mockCardService.Setup(s => s.GetById("c1")).Returns(new Card { CardUId = "c1", ListUId = "l1" });
        _mockListService.Setup(s => s.GetListByIdAsync("l1")).ReturnsAsync(new List { ListUId = "l1", BoardUId = "b1" });

        var result = await _controller.Delete("cm1", "u1");

        Assert.IsType<OkObjectResult>(result);
        _mockClientProxy.Verify(c => c.SendCoreAsync("CommentDeleted", It.IsAny<object[]>(), default), Times.Once);
    }
}
