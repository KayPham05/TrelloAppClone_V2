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
        private readonly IWebHostEnvironment _environment;

        public NotificationController(
            INotificationService notificationService,
            IWebHostEnvironment environment)
        {
            _notificationService = notificationService;
            _environment = environment;
        }

        private string? GetUserId()
        {
            return User.FindFirst("UserUId")?.Value;
        }

        [HttpGet]
        public async Task<IActionResult> GetNotifications(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string tab = "all")
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            var parsedTab = ParseTab(tab);
            var pageDto = await _notificationService.GetNotificationsAsync(userId, parsedTab, page, pageSize);
            return Ok(pageDto);
        }

        [HttpGet("unread-count")]
        public async Task<IActionResult> GetUnreadCount()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            var count = await _notificationService.GetUnreadCountAsync(userId);
            return Ok(new { unreadCount = count });
        }

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

        [HttpPatch("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "User not authenticated" });

            var count = await _notificationService.MarkAllAsReadAsync(userId);
            return Ok(new { updatedCount = count });
        }

        [HttpPost]
        public IActionResult CreateNotification()
        {
            if (_environment.IsDevelopment())
                return StatusCode(403, new { message = "Manual notification creation is disabled. Use server-side business events." });

            return NotFound();
        }

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

        private static NotificationTab ParseTab(string tab)
        {
            return tab.Trim().ToLowerInvariant() switch
            {
                "senttome" => NotificationTab.SentToMe,
                "sent-to-me" => NotificationTab.SentToMe,
                "me" => NotificationTab.SentToMe,
                "unread" => NotificationTab.Unread,
                "read" => NotificationTab.Read,
                "readed" => NotificationTab.Read,
                "da-doc" => NotificationTab.Read,
                _ => NotificationTab.All
            };
        }
    }
}
