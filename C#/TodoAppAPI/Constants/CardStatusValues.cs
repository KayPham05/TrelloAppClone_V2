using TodoAppAPI.Models;

namespace TodoAppAPI.Constants
{
    public static class CardStatusValues
    {
        public const string Completed = "completed";
        public const string ToDo = "to_do";
        public const string DueSoon = "due_soon";
        public const string Overdue = "overdue";
        private const string LegacyDeleted = "Deleted";

        public const string DueDateInPastMessage = "Ngày hết hạn không được trong quá khứ";
        public const string StartDateAfterDueDateMessage = "Ngày bắt đầu không được lớn hơn ngày hết hạn";

        private static readonly Dictionary<string, string> LegacyStatusMap = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Hoàn thành"] = Completed,
            ["Hoan thanh"] = Completed,
            ["hoan_thanh"] = Completed,
            ["Done"] = Completed,
            ["Completed"] = Completed,
            ["Complete"] = Completed,
            ["complete"] = Completed,
            [Completed] = Completed,
            ["To Do"] = ToDo,
            ["ToDo"] = ToDo,
            ["todo"] = ToDo,
            ["To do"] = ToDo,
            ["Todo"] = ToDo,
            ["TODO"] = ToDo,
            [ToDo] = ToDo,
            ["Due_soon"] = DueSoon,
            ["Duesoon"] = DueSoon,
            ["DueSoon"] = DueSoon,
            ["Due Soon"] = DueSoon,
            ["Sắp hết hạn"] = DueSoon,
            ["Sap het han"] = DueSoon,
            [DueSoon] = DueSoon,
            ["Overdue"] = Overdue,
            ["Over Due"] = Overdue,
            ["Hết hạn"] = Overdue,
            ["Het han"] = Overdue,
            [Overdue] = Overdue
        };

        public static string Normalize(string? status)
        {
            var trimmed = status?.Trim();
            if (string.IsNullOrWhiteSpace(trimmed))
                return ToDo;

            return LegacyStatusMap.TryGetValue(trimmed, out var normalized)
                ? normalized
                : ToDo;
        }

        public static bool IsValid(string? status)
        {
            var trimmed = status?.Trim();
            return trimmed == Completed || trimmed == ToDo || trimmed == DueSoon || trimmed == Overdue;
        }

        public static bool IsCompleted(string? status) => Normalize(status) == Completed;
        public static bool IsOverdue(string? status) => Normalize(status) == Overdue;
        public static bool IsDueSoon(string? status) => Normalize(status) == DueSoon;
        public static bool IsLegacyDeleted(string? status) =>
            string.Equals(status?.Trim(), LegacyDeleted, StringComparison.OrdinalIgnoreCase);

        public static string CalculateStatus(string? currentStatus, DateTime? dueDate, DateTime? nowUtc = null)
        {
            if (IsCompleted(currentStatus))
                return Completed;

            return CalculateOpenStatus(dueDate, nowUtc ?? DateTime.UtcNow);
        }

        public static string CalculateOpenStatus(DateTime? dueDate, DateTime nowUtc)
        {
            if (!dueDate.HasValue)
                return ToDo;

            var dueUtc = ToUtc(dueDate.Value);
            if (dueUtc < nowUtc)
                return Overdue;

            return dueUtc <= nowUtc.AddDays(1) ? DueSoon : ToDo;
        }

        public static bool ApplyCalculatedStatus(Card card, DateTime? nowUtc = null)
        {
            var nextStatus = CalculateStatus(card.Status, card.DueDate, nowUtc ?? DateTime.UtcNow);
            if (card.Status == nextStatus)
                return false;

            card.Status = nextStatus;
            return true;
        }

        public static bool IsDueDateInPast(DateTime? dueDate, DateTime? nowUtc = null)
        {
            return dueDate.HasValue && ToUtc(dueDate.Value) < (nowUtc ?? DateTime.UtcNow);
        }

        public static DateTime ToUtc(DateTime value)
        {
            return value.Kind switch
            {
                DateTimeKind.Utc => value,
                DateTimeKind.Local => value.ToUniversalTime(),
                _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
            };
        }
    }
}
