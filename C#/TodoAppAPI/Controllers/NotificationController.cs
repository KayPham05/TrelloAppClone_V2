using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/notifications")]
    [ApiController]
    [Authorize]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        private string? GetUserId()
        {
            return User.FindFirst("UserUId")?.Value;
        }

        // Lấy danh sách thông báo gần đây của người dùng
        [HttpGet]
        public async Task<IActionResult> GetNotifications([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            var items = await _notificationService.GetNotificationsAsync(userId, page, pageSize);
            return Ok(items);
        }

        // Đánh dấu 1 thông báo là đã đọc
        [HttpPatch("{notiId}/read")]
        public async Task<IActionResult> MarkAsRead(string notiId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            var result = await _notificationService.MarkAsReadAsync(userId, notiId);
            if (!result)
                return NotFound(new { message = "Notification not found or unauthorized" });
            return Ok(new { message = "Marked as read" });
        }

        // Đánh dấu tất cả thông báo là đã đọc cho người dùng
        [HttpPatch("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            var count = await _notificationService.MarkAllAsReadAsync(userId);
            return Ok(new { message = $"Marked {count} notifications as read" });
        }

        // Tạo thông báo mới
        [HttpPost]
        public async Task<IActionResult> CreateNotification([FromBody] NotificationDTO dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var noti = await _notificationService.CreateAsync(dto);
            if (noti == null)
                return StatusCode(500, new { message = "Failed to create notification" });

            return Ok(noti);
        }


        // Xóa thông báo
        [HttpDelete("{notiId}")]
        public async Task<IActionResult> DeleteNotification(string notiId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            if (string.IsNullOrWhiteSpace(notiId))
                return BadRequest(new { message = "notiId is required" });

            var deleted = await _notificationService.DeleteAsync(userId, notiId);
            if (!deleted)
                return NotFound(new { message = "Notification not found, unauthorized or already deleted" });

            return Ok(new { message = "Notification deleted successfully" });
        }


    }
}
