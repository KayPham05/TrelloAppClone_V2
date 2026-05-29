using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface INotificationService
    {
        Task<NotificationPageDto> GetNotificationsAsync(string userId, NotificationTab tab, int page, int pageSize);
        Task<int> GetUnreadCountAsync(string userId);
        Task<bool> MarkAsReadAsync(string userId, string notiId);
        Task<int> MarkAllAsReadAsync(string userId);
        Task<Notification?> CreateInternalAsync(NotificationDTO dto);
        Task<IReadOnlyList<Notification>> CreateManyInternalAsync(IEnumerable<NotificationDTO> dtos);
        Task<bool> DeleteAsync(string userId, string notiId);
    }
}
