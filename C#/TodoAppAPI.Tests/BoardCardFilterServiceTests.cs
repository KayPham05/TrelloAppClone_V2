using Microsoft.EntityFrameworkCore;
using Moq;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using Xunit;
using ModelList = TodoAppAPI.Models.List;

namespace TodoAppAPI.Tests;

public class BoardCardFilterServiceTests
{
    [Fact]
    public async Task FilterCardsByBoardAsync_without_filters_returns_current_board_cards_only()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest(), "me");

        AssertSuccessIds(result, "no-members", "assigned-me", "member-a", "members-ab", "overdue", "next-month", "description-card");
        Assert.DoesNotContain(result.Cards, c => c.CardUId == "other-board");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_excludes_archived_cards()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest(), "me");

        Assert.DoesNotContain(result.Cards, c => c.CardUId == "archived");
    }

    [Theory]
    [InlineData("alpha task", "assigned-me")]
    [InlineData("release NOTE", "description-card")]
    public async Task FilterCardsByBoardAsync_keyword_matches_title_or_description_case_insensitive(string keyword, string expectedCardId)
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { Keyword = keyword }, "me");

        AssertSuccessIds(result, expectedCardId);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_no_members_returns_cards_without_members()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { NoMembers = true }, "me");

        AssertSuccessIds(result, "no-members", "next-month", "description-card");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_assigned_to_me_uses_current_user()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { AssignedToMe = true }, "me");

        AssertSuccessIds(result, "assigned-me");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_filters_one_other_member()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { MemberUIds = ["member-a"] }, "me");

        AssertSuccessIds(result, "member-a", "members-ab");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_multiple_members_exact_requires_all_members()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                MemberUIds = ["member-a", "member-b"],
                MatchMode = BoardCardFilterValues.MatchExact
            },
            "me");

        AssertSuccessIds(result, "members-ab");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_multiple_members_any_requires_any_member()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                MemberUIds = ["member-a", "member-b"],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "member-a", "members-ab", "overdue");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_completed_uses_standard_status()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest { CompletionStatus = BoardCardFilterValues.CompletionCompleted },
            "me");

        AssertSuccessIds(result, "member-a");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_incomplete_includes_to_do_due_soon_and_overdue()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest { CompletionStatus = BoardCardFilterValues.CompletionIncomplete },
            "me");

        AssertSuccessIds(result, "no-members", "assigned-me", "members-ab", "overdue", "next-month", "description-card");
    }

    [Theory]
    [InlineData(BoardCardFilterValues.DueOverdue, "overdue")]
    [InlineData(BoardCardFilterValues.DueNoDate, "no-members", "description-card")]
    [InlineData(BoardCardFilterValues.DueNextWeek, "assigned-me", "members-ab")]
    [InlineData(BoardCardFilterValues.DueNextMonth, "assigned-me", "member-a", "members-ab", "next-month")]
    public async Task FilterCardsByBoardAsync_due_date_filters(string dueFilter, params string[] expectedIds)
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest { DueDateFilters = [dueFilter] },
            "me");

        AssertSuccessIds(result, expectedIds);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_no_labels_returns_cards_without_labels()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { NoLabels = true }, "me");

        AssertSuccessIds(result, "no-members", "overdue", "description-card");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_filters_one_label()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { LabelUIds = ["label-p1-a"] }, "me");

        AssertSuccessIds(result, "assigned-me");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_multiple_labels_exact_requires_all_labels()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                LabelUIds = ["label-p1-b", "label-p2-b"],
                MatchMode = BoardCardFilterValues.MatchExact
            },
            "me");

        AssertSuccessIds(result, "member-a");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_multiple_labels_any_requires_any_label()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                LabelUIds = ["label-p1-b", "label-p2-c"],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "member-a", "members-ab");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_group_any_matches_any_id_in_group()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups = [LabelGroup("label-p1-a", "label-p1-b")],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "assigned-me", "member-a");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_group_exact_with_one_group_matches_any_id_in_group()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups = [LabelGroup("label-p1-a", "label-p1-b")],
                MatchMode = BoardCardFilterValues.MatchExact
            },
            "me");

        AssertSuccessIds(result, "assigned-me", "member-a");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_group_exact_with_two_groups_requires_each_group()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups =
                [
                    LabelGroup("label-p1-a", "label-p1-b"),
                    LabelGroup("label-p2-b", "label-p2-c")
                ],
                MatchMode = BoardCardFilterValues.MatchExact
            },
            "me");

        AssertSuccessIds(result, "member-a");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_group_any_with_two_groups_matches_either_group()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups =
                [
                    LabelGroup("label-p1-a", "label-p1-b"),
                    LabelGroup("label-p2-b", "label-p2-c")
                ],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "assigned-me", "member-a", "members-ab");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_group_duplicate_ids_are_deduped()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups = [LabelGroup("label-p1-b", "label-p1-b")],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "member-a");
        Assert.Equal(result.Cards.Count, result.Cards.Select(c => c.CardUId).Distinct().Count());
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_empty_label_group_returns_bad_request()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups = [LabelGroup()]
            },
            "me");

        Assert.Equal(BoardCardFilterResultStatus.BadRequest, result.Status);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_group_from_other_board_returns_bad_request()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                SelectedLabelGroups = [LabelGroup("label-other")]
            },
            "me");

        Assert.Equal(BoardCardFilterResultStatus.BadRequest, result.Status);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_exact_combines_all_selected_predicates_with_and()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                MemberUIds = ["member-a"],
                CompletionStatus = BoardCardFilterValues.CompletionCompleted,
                DueDateFilters = [BoardCardFilterValues.DueNextMonth],
                LabelUIds = ["label-p1-b"],
                MatchMode = BoardCardFilterValues.MatchExact
            },
            "me");

        AssertSuccessIds(result, "member-a");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_any_combines_selected_predicates_with_or()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                Keyword = "release",
                AssignedToMe = true,
                LabelUIds = ["label-p3"],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "assigned-me", "next-month", "description-card");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_keyword_exact_requires_other_filters_too()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                Keyword = "alpha",
                LabelUIds = ["label-p1-a"],
                MatchMode = BoardCardFilterValues.MatchExact
            },
            "me");

        AssertSuccessIds(result, "assigned-me");
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_empty_result_is_success()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { Keyword = "missing keyword" }, "me");

        Assert.Equal(BoardCardFilterResultStatus.Success, result.Status);
        Assert.Empty(result.Cards);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_unknown_board_returns_not_found()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("missing", new BoardCardFilterRequest(), "me");

        Assert.Equal(BoardCardFilterResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_user_without_access_returns_forbidden()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest(), "outsider");

        Assert.Equal(BoardCardFilterResultStatus.Forbidden, result.Status);
    }

    [Theory]
    [InlineData("sideways", null, null)]
    [InlineData(BoardCardFilterValues.MatchExact, "Completed", null)]
    [InlineData(BoardCardFilterValues.MatchExact, null, "today")]
    public async Task FilterCardsByBoardAsync_invalid_request_values_return_bad_request(
        string matchMode,
        string? completionStatus,
        string? dueDateFilter)
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var request = new BoardCardFilterRequest
        {
            MatchMode = matchMode,
            CompletionStatus = completionStatus,
            DueDateFilters = dueDateFilter == null ? [] : [dueDateFilter]
        };
        var result = await service.FilterCardsByBoardAsync("board-1", request, "me");

        Assert.Equal(BoardCardFilterResultStatus.BadRequest, result.Status);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_member_outside_board_returns_bad_request()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { MemberUIds = ["outsider"] }, "me");

        Assert.Equal(BoardCardFilterResultStatus.BadRequest, result.Status);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_label_from_other_board_returns_bad_request()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync("board-1", new BoardCardFilterRequest { LabelUIds = ["label-other"] }, "me");

        Assert.Equal(BoardCardFilterResultStatus.BadRequest, result.Status);
    }

    [Fact]
    public async Task FilterCardsByBoardAsync_any_label_filter_does_not_duplicate_cards()
    {
        await using var context = CreateContext();
        SeedBoard(context);
        var service = CreateService(context);

        var result = await service.FilterCardsByBoardAsync(
            "board-1",
            new BoardCardFilterRequest
            {
                LabelUIds = ["label-p1-b", "label-p2-b"],
                MatchMode = BoardCardFilterValues.MatchAny
            },
            "me");

        AssertSuccessIds(result, "member-a");
        Assert.Equal(result.Cards.Count, result.Cards.Select(c => c.CardUId).Distinct().Count());
    }

    private static TodoDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<TodoDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new TodoDbContext(options);
    }

    private static CardsService CreateService(TodoDbContext context)
    {
        var auth = new AuthorizationService(context);
        var notifications = new Mock<INotificationService>();
        var reminders = new Mock<ICardDueDateReminderService>();
        return new CardsService(context, auth, notifications.Object, reminders.Object);
    }

    private static void AssertSuccessIds(BoardCardFilterResult result, params string[] expectedIds)
    {
        Assert.Equal(BoardCardFilterResultStatus.Success, result.Status);
        Assert.Equal(expectedIds, result.Cards.Select(c => c.CardUId).ToArray());
    }

    private static BoardCardLabelFilterGroupRequest LabelGroup(params string[] labelUIds) => new()
    {
        CardLabelUIds = labelUIds.ToList()
    };

    private static void SeedBoard(TodoDbContext context)
    {
        var now = DateTime.UtcNow;
        context.Users.AddRange(
            User("owner"),
            User("me"),
            User("member-a"),
            User("member-b"),
            User("outsider"));

        context.Boards.AddRange(
            new Board { BoardUId = "board-1", BoardName = "Board 1", UserUId = "owner" },
            new Board { BoardUId = "board-2", BoardName = "Board 2", UserUId = "owner" });

        context.BoardMembers.AddRange(
            BoardMember("board-1", "owner", "Owner"),
            BoardMember("board-1", "me", "Editor"),
            BoardMember("board-1", "member-a", "Editor"),
            BoardMember("board-1", "member-b", "Viewer"),
            BoardMember("board-2", "owner", "Owner"),
            BoardMember("board-2", "outsider", "Editor"));

        context.Lists.AddRange(
            new ModelList { ListUId = "list-1", BoardUId = "board-1", ListName = "To do", Position = 0, Status = "Active" },
            new ModelList { ListUId = "list-2", BoardUId = "board-1", ListName = "Doing", Position = 1, Status = "Active" },
            new ModelList { ListUId = "list-other", BoardUId = "board-2", ListName = "Other", Position = 0, Status = "Active" });

        context.Todos.AddRange(
            Card("no-members", "list-1", "No members", null, CardStatusValues.ToDo, null, 0),
            Card("assigned-me", "list-1", "Alpha task", "owned by me", CardStatusValues.ToDo, now.AddDays(3), 1),
            Card("member-a", "list-1", "Completed item", "done", CardStatusValues.Completed, now.AddDays(20), 2),
            Card("members-ab", "list-1", "Two members", "shared", CardStatusValues.DueSoon, now.AddDays(7), 3),
            Card("overdue", "list-2", "Late bug", "past due", CardStatusValues.Overdue, now.AddDays(-1), 0),
            Card("next-month", "list-2", "Monthly report", "future", CardStatusValues.ToDo, now.AddDays(30), 1),
            Card("description-card", "list-2", "Plain title", "Release note body", CardStatusValues.ToDo, null, 2),
            Card("archived", "list-2", "Archived", "hidden", CardStatusValues.ToDo, null, 3, isArchived: true),
            Card("other-board", "list-other", "Other board", "must not leak", CardStatusValues.ToDo, null, 0));

        context.CardMembers.AddRange(
            CardMember("assigned-me", "me"),
            CardMember("member-a", "member-a"),
            CardMember("members-ab", "member-a"),
            CardMember("members-ab", "member-b"),
            CardMember("overdue", "member-b"),
            CardMember("other-board", "outsider"));

        context.CardLabels.AddRange(
            Label("label-p1-a", "assigned-me", "P1", "#ff0000"),
            Label("label-p1-b", "member-a", "P1", "#ff0000"),
            Label("label-p2-b", "member-a", "P2", "#00ff00"),
            Label("label-p2-c", "members-ab", "P2", "#00ff00"),
            Label("label-p3", "next-month", "P3", "#0000ff"),
            Label("label-other", "other-board", "Other", "#999999"));

        context.SaveChanges();
    }

    private static User User(string id) => new()
    {
        UserUId = id,
        UserName = id,
        Email = $"{id}@example.com",
        PasswordHash = "hash",
        StatusAccount = "Active"
    };

    private static BoardMember BoardMember(string boardId, string userId, string role) => new()
    {
        BoardMemberUId = $"{boardId}-{userId}",
        BoardUId = boardId,
        UserUId = userId,
        BoardRole = role
    };

    private static Card Card(
        string id,
        string listId,
        string title,
        string? description,
        string status,
        DateTime? dueDate,
        int position,
        bool isArchived = false) => new()
    {
        CardUId = id,
        ListUId = listId,
        Title = title,
        Description = description,
        Status = status,
        DueDate = dueDate,
        Position = position,
        UserUId = "owner",
        IsArchived = isArchived
    };

    private static CardMember CardMember(string cardId, string userId) => new()
    {
        CardMemberUId = $"{cardId}-{userId}",
        CardUId = cardId,
        UserUId = userId,
        Role = "Assignee"
    };

    private static CardLabel Label(string id, string cardId, string title, string color) => new()
    {
        CardLabelUId = id,
        CardUId = cardId,
        Title = title,
        ColorCode = color
    };
}
