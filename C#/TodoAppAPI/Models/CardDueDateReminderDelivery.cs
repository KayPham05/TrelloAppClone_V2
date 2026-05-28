namespace TodoAppAPI.Models
{
    public class CardDueDateReminderDelivery
    {
        public string ReminderDeliveryId { get; set; } = Guid.NewGuid().ToString();
        public string CardUId { get; set; } = default!;
        public DueDateReminderMilestone Milestone { get; set; }
        public DateTime DueDateSnapshot { get; set; }
        public DateTime SentAt { get; set; }

        public Card Card { get; set; } = default!;
    }
}
