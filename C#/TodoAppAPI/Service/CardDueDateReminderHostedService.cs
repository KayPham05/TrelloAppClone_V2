using Microsoft.Extensions.DependencyInjection;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Service
{
    public class CardDueDateReminderHostedService : BackgroundService
    {
        private static readonly TimeSpan Interval = TimeSpan.FromMinutes(15);
        private readonly IServiceScopeFactory _scopeFactory;

        public CardDueDateReminderHostedService(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                await RunOnceAsync(stoppingToken);

                using var timer = new PeriodicTimer(Interval);
                while (await timer.WaitForNextTickAsync(stoppingToken))
                {
                    await RunOnceAsync(stoppingToken);
                }
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
            }
        }

        private async Task RunOnceAsync(CancellationToken stoppingToken)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var service = scope.ServiceProvider.GetRequiredService<ICardDueDateReminderService>();
                await service.SendDueRemindersAsync(DateTime.Now, stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Card due-date reminder scheduler failed: {ex.Message}");
            }
        }
    }
}
