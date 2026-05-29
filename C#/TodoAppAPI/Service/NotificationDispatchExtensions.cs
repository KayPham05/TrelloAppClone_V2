using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public static class NotificationDispatchExtensions
    {
        public static async Task TryCreateInternalAsync(
            this INotificationService notificationService,
            NotificationDTO dto,
            string action)
        {
            try
            {
                await notificationService.CreateInternalAsync(dto);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification dispatch failed during {action}: {ex.Message}");
            }
        }

        public static async Task TryCreateManyInternalAsync(
            this INotificationService notificationService,
            IEnumerable<NotificationDTO> dtos,
            string action)
        {
            try
            {
                await notificationService.CreateManyInternalAsync(dtos);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification dispatch failed during {action}: {ex.Message}");
            }
        }
    }
}
