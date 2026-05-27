namespace TodoAppAPI.Interfaces
{
    public interface ICardDueDateReminderService
    {
        Task<int> SendDueRemindersAsync(DateTime now, CancellationToken cancellationToken = default);
        Task ResetReminderHistoryAsync(string cardUId, CancellationToken cancellationToken = default);
    }
}
