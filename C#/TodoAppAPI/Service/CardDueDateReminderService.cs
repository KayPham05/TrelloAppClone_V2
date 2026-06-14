using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class CardDueDateReminderService : ICardDueDateReminderService
    {
        private readonly TodoDbContext _context;
        private readonly INotificationService _notificationService;

        public CardDueDateReminderService(
            TodoDbContext context,
            INotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        public async Task<int> SendDueRemindersAsync(DateTime now, CancellationToken cancellationToken = default)
        {
            var cards = await _context.Todos
                .AsNoTracking()
                .Include(c => c.List)
                .Include(c => c.CardMembers)
                .Where(c => c.DueDate.HasValue)
                .Where(c => c.DueDate <= now.AddDays(1))
                .Where(c => !c.IsArchived)
                .Where(c => c.CardMembers!.Any())
                .ToListAsync(cancellationToken);

            var sentMilestoneCount = 0;
            foreach (var card in cards)
            {
                cancellationToken.ThrowIfCancellationRequested();

                if (ShouldSkip(card))
                    continue;

                var milestone = ResolveMilestone(card.DueDate!.Value, now);
                if (milestone == null)
                    continue;

                var alreadySent = await _context.CardDueDateReminderDeliveries
                    .AnyAsync(d => d.CardUId == card.CardUId && d.Milestone == milestone, cancellationToken);
                if (alreadySent)
                    continue;

                var recipientIds = card.CardMembers?
                    .Select(cm => cm.UserUId)
                    .Where(id => !string.IsNullOrWhiteSpace(id))
                    .Distinct()
                    .ToList() ?? new List<string>();

                if (recipientIds.Count == 0)
                    continue;

                var delivery = new CardDueDateReminderDelivery
                {
                    ReminderDeliveryId = Guid.NewGuid().ToString(),
                    CardUId = card.CardUId,
                    Milestone = milestone.Value,
                    DueDateSnapshot = card.DueDate.Value,
                    SentAt = now
                };

                _context.CardDueDateReminderDeliveries.Add(delivery);
                try
                {
                    await _context.SaveChangesAsync(cancellationToken);
                }
                catch (DbUpdateException)
                {
                    DetachPendingReminderDelivery(card.CardUId, milestone.Value);
                    continue;
                }

                var notifications = recipientIds.Select(recipientId => BuildNotification(card, recipientId, milestone.Value)).ToList();
                var created = await _notificationService.CreateManyInternalAsync(notifications);
                if (created.Count == 0)
                {
                    _context.CardDueDateReminderDeliveries.Remove(delivery);
                    await _context.SaveChangesAsync(cancellationToken);
                    continue;
                }

                sentMilestoneCount++;
            }

            return sentMilestoneCount;
        }

        public async Task ResetReminderHistoryAsync(string cardUId, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(cardUId))
                return;

            var deliveries = await _context.CardDueDateReminderDeliveries
                .Where(d => d.CardUId == cardUId)
                .ToListAsync(cancellationToken);

            if (deliveries.Count == 0)
                return;

            _context.CardDueDateReminderDeliveries.RemoveRange(deliveries);
            await _context.SaveChangesAsync(cancellationToken);
        }

        private static NotificationDTO BuildNotification(
            Card card,
            string recipientId,
            DueDateReminderMilestone milestone)
        {
            var title = card.Title?.Trim();
            if (string.IsNullOrWhiteSpace(title))
                title = card.CardUId;

            return new NotificationDTO
            {
                RecipientId = recipientId,
                ActorId = null,
                Type = NotificationType.DueDateReminder,
                Title = ReminderTitle(milestone),
                Message = ReminderMessage(title, card.DueDate!.Value, milestone),
                BoardId = card.List?.BoardUId,
                ListId = card.ListUId,
                CardId = card.CardUId,
                Link = $"/card-detail/{card.CardUId}"
            };
        }

        private static string ReminderTitle(DueDateReminderMilestone milestone) =>
            milestone switch
            {
                DueDateReminderMilestone.OneDayBefore => "Card is due in 1 day",
                DueDateReminderMilestone.OneHourBefore => "Card is due in 1 hour",
                DueDateReminderMilestone.DueNow => "Card is due now",
                _ => "Card due reminder"
            };

        private static string ReminderMessage(string title, DateTime dueDate, DueDateReminderMilestone milestone) =>
            milestone switch
            {
                DueDateReminderMilestone.OneDayBefore => $"Card '{title}' is due on {dueDate:yyyy-MM-dd HH:mm}.",
                DueDateReminderMilestone.OneHourBefore => $"Card '{title}' is due at {dueDate:yyyy-MM-dd HH:mm}.",
                DueDateReminderMilestone.DueNow => $"Card '{title}' is due now or overdue.",
                _ => $"Card '{title}' has an upcoming due date."
            };

        private static DueDateReminderMilestone? ResolveMilestone(DateTime dueDate, DateTime now)
        {
            if (dueDate <= now)
                return DueDateReminderMilestone.DueNow;

            if (dueDate <= now.AddHours(1))
                return DueDateReminderMilestone.OneHourBefore;

            if (dueDate <= now.AddDays(1))
                return DueDateReminderMilestone.OneDayBefore;

            return null;
        }

        private static bool ShouldSkip(Card card)
        {
            return CardStatusValues.IsCompleted(card.Status)
                || CardStatusValues.IsLegacyDeleted(card.Status);
        }

        private void DetachPendingReminderDelivery(string cardUId, DueDateReminderMilestone milestone)
        {
            var pendingEntries = _context.ChangeTracker
                .Entries<CardDueDateReminderDelivery>()
                .Where(e =>
                    e.Entity.CardUId == cardUId &&
                    e.Entity.Milestone == milestone &&
                    e.State == EntityState.Added)
                .ToList();

            foreach (var entry in pendingEntries)
            {
                entry.State = EntityState.Detached;
            }
        }
    }
}
