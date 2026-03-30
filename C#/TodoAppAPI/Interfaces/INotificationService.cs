using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface INotificationService
    {
        Task<IEnumerable<Notification>> GetNotificationsAsync(string userId, int page, int pageSize);
        Task<bool> MarkAsReadAsync(string notiId);
        Task<int> MarkAllAsReadAsync(string userId);
        Task<Notification> CreateAsync(NotificationDTO dto);
        Task<bool> DeleteAsync(string notiId);
    }
}
