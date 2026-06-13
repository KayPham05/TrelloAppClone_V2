using TodoAppAPI.Models;

namespace TodoAppAPI.DTOs
{
    public class BoardCardFilterRequest
    {
        public string? Keyword { get; set; }
        public bool NoMembers { get; set; }
        public bool AssignedToMe { get; set; }
        public List<string> MemberUIds { get; set; } = new();
        public string? CompletionStatus { get; set; }
        public List<string> DueDateFilters { get; set; } = new();
        public bool NoLabels { get; set; }
        public List<string> LabelUIds { get; set; } = new();
        public List<BoardCardLabelFilterGroupRequest> SelectedLabelGroups { get; set; } = new();
        public string MatchMode { get; set; } = BoardCardFilterValues.MatchExact;
    }

    public class BoardCardLabelFilterGroupRequest
    {
        public List<string> CardLabelUIds { get; set; } = new();
    }

    public static class BoardCardFilterValues
    {
        public const string MatchExact = "exact";
        public const string MatchAny = "any";
        public const string CompletionCompleted = "completed";
        public const string CompletionIncomplete = "incomplete";
        public const string DueOverdue = "overdue";
        public const string DueNoDate = "no_due_date";
        public const string DueNextWeek = "next_week";
        public const string DueNextMonth = "next_month";
    }

    public enum BoardCardFilterResultStatus
    {
        Success,
        BadRequest,
        Forbidden,
        NotFound
    }

    public class BoardCardFilterResult
    {
        public BoardCardFilterResultStatus Status { get; init; }
        public string? Message { get; init; }
        public List<Card> Cards { get; init; } = new();

        public static BoardCardFilterResult Success(List<Card> cards) =>
            new() { Status = BoardCardFilterResultStatus.Success, Cards = cards };

        public static BoardCardFilterResult BadRequest(string message) =>
            new() { Status = BoardCardFilterResultStatus.BadRequest, Message = message };

        public static BoardCardFilterResult Forbidden(string message) =>
            new() { Status = BoardCardFilterResultStatus.Forbidden, Message = message };

        public static BoardCardFilterResult NotFound(string message) =>
            new() { Status = BoardCardFilterResultStatus.NotFound, Message = message };
    }
}
