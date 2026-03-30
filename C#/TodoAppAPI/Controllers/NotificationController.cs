using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/notifications")]
    [ApiController]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        // Lấy danh sách thông báo gần đây của người dùng
        [HttpGet]
        public async Task<IActionResult> GetNotifications([FromQuery] string userId, [FromQuery] int page, [FromQuery] int pageSize)
        {
            if (string.IsNullOrEmpty(userId))
                return BadRequest(new { message = "userId is required" });

            var items = await _notificationService.GetNotificationsAsync(userId, page, pageSize);
            return Ok(items);
        }

        // Đánh dấu 1 thông báo là đã đọc
        [HttpPatch("{notiId}/read")]
        public async Task<IActionResult> MarkAsRead(string notiId)
        {
            var result = await _notificationService.MarkAsReadAsync(notiId);
            if (!result)
                return NotFound(new { message = "Notification not found" });
            return Ok(new { message = "Marked as read" });
        }

        // Đánh dấu tất cả thông báo là đã đọc cho người dùng
        [HttpPatch("read-all")]
        public async Task<IActionResult> MarkAllAsRead([FromQuery] string userId)
        {
            if (string.IsNullOrEmpty(userId))
                return BadRequest(new { message = "userId is required" });

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
            if (string.IsNullOrWhiteSpace(notiId))
                return BadRequest(new { message = "notiId is required" });

            var deleted = await _notificationService.DeleteAsync(notiId);
            if (!deleted)
                return NotFound(new { message = "Notification not found or already deleted" });

            return Ok(new { message = "Notification deleted successfully" });
        }


    }
}
