using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class CardsService : ICardsService
    {
        private readonly TodoDbContext _dbContext;
        private readonly IAuthorizationService _authService;
        private readonly INotificationService _notificationService;
        private readonly ICardDueDateReminderService _dueDateReminderService;

        public CardsService(
            TodoDbContext dbContext,
            IAuthorizationService authService,
            INotificationService notificationService,
            ICardDueDateReminderService dueDateReminderService)
        {
            _dbContext = dbContext;
            _authService = authService;
            _notificationService = notificationService;
            _dueDateReminderService = dueDateReminderService;
        }
        public async Task<bool> AddCard(Card card)
        {
            try
            {
                // Check permission to add card to list
                if (!string.IsNullOrEmpty(card.ListUId))
                {
                    var list = await _dbContext.Lists.FindAsync(card.ListUId);
                    if (list != null)
                    {
                        if (!await _authService.CanCreateCardAsync(list.BoardUId, card.UserUId))
                            return false;
                    }
                }

                card.CardUId = Guid.NewGuid().ToString();

                if (string.IsNullOrEmpty(card.ListUId))
                    card.ListUId = null; // Inbox mặc định (null)

                if (CardStatusValues.IsDueDateInPast(card.DueDate))
                    return false;

                CardStatusValues.ApplyCalculatedStatus(card);

                _dbContext.Todos.Add(card);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm Card: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteCard(string Uid, string userUId)
        {
            try
            {
                if (!await _authService.CanDeleteCardAsync(Uid, userUId))
                    return false;

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == Uid);
                if (card == null) return false;

                _dbContext.Todos.Remove(card);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi xóa Card: {ex.Message}");
                return false;
            }
        }

        public Card? GetById(string cardUId)
        {
            var card = _dbContext.Todos
                .Include(c => c.List).ThenInclude(l => l.Board)
                .Include(c => c.TodoItems)
                .Include(c => c.Comments)
                .Include(c => c.FileUrls)
                .Include(c => c.CardMembers).ThenInclude(m => m.User)
                .Include(c => c.CardLabels)
                .FirstOrDefault(c => c.CardUId == cardUId);

            if (card != null)
            {
                if (CardStatusValues.ApplyCalculatedStatus(card))
                {
                    _dbContext.SaveChanges();
                }

                if (card.List != null)
                {
                    card.ListName = card.List.ListName;
                    if (card.List.Board != null)
                    {
                        card.BoardName = card.List.Board.BoardName;
                        card.BoardBackgroundUrl = card.List.Board.BackgroundUrl;
                    }
                }
            }

            return card;
        }

        public List<Card> GetCardsByBoardId(string boardUId)
        {
            var cards = _dbContext.Todos
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.Comments)
                .Include(c => c.FileUrls)
                .Include(c => c.CardMembers).ThenInclude(m => m.User)
                .Include(c => c.CardLabels)
                .Where(c => c.List != null && c.List.BoardUId == boardUId && !c.IsArchived)
                .ToList();

            var now = DateTime.UtcNow;
            var changed = false;
            foreach (var item in cards)
            {
                changed = CardStatusValues.ApplyCalculatedStatus(item, now) || changed;
            }

            if (changed)
            {
                _dbContext.SaveChanges();
            }

            return cards;
        }

        public async Task<BoardCardFilterResult> FilterCardsByBoardAsync(string boardUId, BoardCardFilterRequest request, string userUId)
        {
            request ??= new BoardCardFilterRequest();
            var normalized = NormalizeFilterRequest(request);
            if (normalized.ErrorMessage != null)
                return BoardCardFilterResult.BadRequest(normalized.ErrorMessage);

            var boardExists = await _dbContext.Boards
                .AsNoTracking()
                .AnyAsync(b => b.BoardUId == boardUId && b.Status != "Deleted");
            if (!boardExists)
                return BoardCardFilterResult.NotFound("Board khÃ´ng tá»“n táº¡i.");

            if (!await _authService.CanViewBoardAsync(boardUId, userUId))
                return BoardCardFilterResult.Forbidden("Báº¡n khÃ´ng cÃ³ quyá»n truy cáº­p board nÃ y.");

            var now = DateTime.UtcNow;
            var query = _dbContext.Todos
                .AsNoTracking()
                .Where(c => c.List != null && c.List.BoardUId == boardUId && !c.IsArchived);

            if (normalized.MemberUIds.Count > 0)
            {
                var validMemberIds = await _dbContext.BoardMembers
                    .AsNoTracking()
                    .Where(bm => bm.BoardUId == boardUId && normalized.MemberUIds.Contains(bm.UserUId))
                    .Select(bm => bm.UserUId)
                    .Distinct()
                    .ToListAsync();

                if (validMemberIds.Count != normalized.MemberUIds.Count)
                    return BoardCardFilterResult.BadRequest("Member filter khÃ´ng há»£p lá»‡ cho board nÃ y.");
            }

            var selectedLabelUIds = normalized.LabelGroups
                .SelectMany(group => group)
                .Distinct()
                .ToList();
            if (selectedLabelUIds.Count > 0)
            {
                var validLabelIds = await _dbContext.CardLabels
                    .AsNoTracking()
                    .Where(cl => cl.Card.List != null &&
                                 cl.Card.List.BoardUId == boardUId &&
                                 selectedLabelUIds.Contains(cl.CardLabelUId))
                    .Select(cl => cl.CardLabelUId)
                    .Distinct()
                    .ToListAsync();

                if (validLabelIds.Count != selectedLabelUIds.Count)
                    return BoardCardFilterResult.BadRequest("Label filter khÃ´ng há»£p lá»‡ cho board nÃ y.");
            }

            if (!normalized.HasAnyPredicate)
            {
                query = ApplyCardIncludes(query);
            }
            else if (normalized.MatchMode == BoardCardFilterValues.MatchExact)
            {
                query = ApplyExactFilter(query, normalized, userUId, now);
                query = ApplyCardIncludes(query);
            }
            else
            {
                query = ApplyAnyFilter(query, normalized, userUId, now);
                query = ApplyCardIncludes(query);
            }

            var cards = await query
                .OrderBy(c => c.List!.Position)
                .ThenBy(c => c.Position)
                .ToListAsync();

            foreach (var card in cards)
            {
                card.Status = CardStatusValues.CalculateStatus(card.Status, card.DueDate, now);
            }

            return BoardCardFilterResult.Success(cards);
        }

        private static IQueryable<Card> ApplyExactFilter(
            IQueryable<Card> query,
            NormalizedBoardCardFilter request,
            string userUId,
            DateTime now)
        {
            if (request.Keyword != null)
            {
                var keyword = request.Keyword;
                query = query.Where(c =>
                    (c.Title != null && c.Title.ToLower().Contains(keyword)) ||
                    (c.Description != null && c.Description.ToLower().Contains(keyword)));
            }

            if (request.NoMembers)
                query = query.Where(c => !c.CardMembers!.Any());

            if (request.AssignedToMe)
                query = query.Where(c => c.CardMembers!.Any(cm => cm.UserUId == userUId));

            foreach (var memberUId in request.MemberUIds)
            {
                var selectedMemberUId = memberUId;
                query = query.Where(c => c.CardMembers!.Any(cm => cm.UserUId == selectedMemberUId));
            }

            if (request.CompletionStatus == BoardCardFilterValues.CompletionCompleted)
                query = query.Where(c => c.Status == CardStatusValues.Completed);
            else if (request.CompletionStatus == BoardCardFilterValues.CompletionIncomplete)
                query = query.Where(c => c.Status != CardStatusValues.Completed);

            foreach (var dueDateFilter in request.DueDateFilters)
            {
                query = ApplyDueDateFilter(query, dueDateFilter, now);
            }

            if (request.NoLabels)
                query = query.Where(c => !c.CardLabels!.Any());

            foreach (var labelGroup in request.LabelGroups)
            {
                var selectedLabelUIds = labelGroup;
                query = query.Where(c => c.CardLabels!.Any(cl => selectedLabelUIds.Contains(cl.CardLabelUId)));
            }

            return query;
        }

        private static IQueryable<Card> ApplyAnyFilter(
            IQueryable<Card> query,
            NormalizedBoardCardFilter request,
            string userUId,
            DateTime now)
        {
            Expression<Func<Card, bool>>? predicate = null;

            if (request.Keyword != null)
            {
                var keyword = request.Keyword;
                predicate = Or(predicate, c =>
                    (c.Title != null && c.Title.ToLower().Contains(keyword)) ||
                    (c.Description != null && c.Description.ToLower().Contains(keyword)));
            }

            if (request.NoMembers)
                predicate = Or(predicate, c => !c.CardMembers!.Any());

            if (request.AssignedToMe)
                predicate = Or(predicate, c => c.CardMembers!.Any(cm => cm.UserUId == userUId));

            if (request.MemberUIds.Count > 0)
            {
                var memberUIds = request.MemberUIds;
                predicate = Or(predicate, c => c.CardMembers!.Any(cm => memberUIds.Contains(cm.UserUId)));
            }

            if (request.CompletionStatus == BoardCardFilterValues.CompletionCompleted)
                predicate = Or(predicate, c => c.Status == CardStatusValues.Completed);
            else if (request.CompletionStatus == BoardCardFilterValues.CompletionIncomplete)
                predicate = Or(predicate, c => c.Status != CardStatusValues.Completed);

            foreach (var dueDateFilter in request.DueDateFilters)
            {
                predicate = Or(predicate, DueDatePredicate(dueDateFilter, now));
            }

            if (request.NoLabels)
                predicate = Or(predicate, c => !c.CardLabels!.Any());

            if (request.LabelGroups.Count > 0)
            {
                var labelUIds = request.LabelGroups.SelectMany(group => group).Distinct().ToList();
                predicate = Or(predicate, c => c.CardLabels!.Any(cl => labelUIds.Contains(cl.CardLabelUId)));
            }

            return predicate == null ? query : query.Where(predicate);
        }

        private static IQueryable<Card> ApplyDueDateFilter(IQueryable<Card> query, string dueDateFilter, DateTime now)
        {
            return dueDateFilter switch
            {
                BoardCardFilterValues.DueOverdue => query.Where(DueDatePredicate(BoardCardFilterValues.DueOverdue, now)),
                BoardCardFilterValues.DueNoDate => query.Where(DueDatePredicate(BoardCardFilterValues.DueNoDate, now)),
                BoardCardFilterValues.DueNextWeek => query.Where(DueDatePredicate(BoardCardFilterValues.DueNextWeek, now)),
                BoardCardFilterValues.DueNextMonth => query.Where(DueDatePredicate(BoardCardFilterValues.DueNextMonth, now)),
                _ => query
            };
        }

        private static Expression<Func<Card, bool>> DueDatePredicate(string dueDateFilter, DateTime now)
        {
            var nextWeek = now.AddDays(7);
            var nextMonth = now.AddDays(30);

            return dueDateFilter switch
            {
                BoardCardFilterValues.DueOverdue =>
                    c => c.DueDate != null && c.DueDate < now && c.Status != CardStatusValues.Completed,
                BoardCardFilterValues.DueNoDate =>
                    c => c.DueDate == null,
                BoardCardFilterValues.DueNextWeek =>
                    c => c.DueDate != null && c.DueDate > now && c.DueDate <= nextWeek,
                BoardCardFilterValues.DueNextMonth =>
                    c => c.DueDate != null && c.DueDate > now && c.DueDate <= nextMonth,
                _ => c => true
            };
        }

        private static IQueryable<Card> ApplyCardIncludes(IQueryable<Card> query)
        {
            return query
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.Comments)
                .Include(c => c.FileUrls)
                .Include(c => c.CardMembers).ThenInclude(m => m.User)
                .Include(c => c.CardLabels);
        }

        private static Expression<Func<Card, bool>> Or(
            Expression<Func<Card, bool>>? left,
            Expression<Func<Card, bool>> right)
        {
            if (left == null) return right;

            var parameter = left.Parameters[0];
            var body = Expression.OrElse(left.Body, new ReplaceParameterVisitor(right.Parameters[0], parameter).Visit(right.Body)!);
            return Expression.Lambda<Func<Card, bool>>(body, parameter);
        }

        private sealed class ReplaceParameterVisitor : ExpressionVisitor
        {
            private readonly ParameterExpression _source;
            private readonly ParameterExpression _target;

            public ReplaceParameterVisitor(ParameterExpression source, ParameterExpression target)
            {
                _source = source;
                _target = target;
            }

            protected override Expression VisitParameter(ParameterExpression node)
            {
                return node == _source ? _target : base.VisitParameter(node);
            }
        }

        private static NormalizedBoardCardFilter NormalizeFilterRequest(BoardCardFilterRequest request)
        {
            var matchMode = string.IsNullOrWhiteSpace(request.MatchMode)
                ? BoardCardFilterValues.MatchExact
                : request.MatchMode.Trim().ToLowerInvariant();

            if (matchMode is not (BoardCardFilterValues.MatchExact or BoardCardFilterValues.MatchAny))
                return NormalizedBoardCardFilter.Invalid("Match mode khÃ´ng há»£p lá»‡.");

            var completionStatus = string.IsNullOrWhiteSpace(request.CompletionStatus)
                ? null
                : request.CompletionStatus.Trim();

            if (completionStatus is not null &&
                completionStatus is not (BoardCardFilterValues.CompletionCompleted or BoardCardFilterValues.CompletionIncomplete))
            {
                return NormalizedBoardCardFilter.Invalid("Completion status khÃ´ng há»£p lá»‡.");
            }

            var dueDateFilters = request.DueDateFilters
                .Select(f => f?.Trim().ToLowerInvariant())
                .Where(f => !string.IsNullOrWhiteSpace(f))
                .Select(f => f!)
                .Distinct()
                .ToList()!;

            var allowedDueDateFilters = new HashSet<string>
            {
                BoardCardFilterValues.DueOverdue,
                BoardCardFilterValues.DueNoDate,
                BoardCardFilterValues.DueNextWeek,
                BoardCardFilterValues.DueNextMonth
            };

            if (dueDateFilters.Any(f => !allowedDueDateFilters.Contains(f)))
                return NormalizedBoardCardFilter.Invalid("Due-date filter khÃ´ng há»£p lá»‡.");

            var memberUIds = NormalizeIds(request.MemberUIds, out var memberError);
            if (memberError != null) return NormalizedBoardCardFilter.Invalid(memberError);

            var labelGroups = NormalizeLabelGroups(request.LabelUIds, request.SelectedLabelGroups, out var labelError);
            if (labelError != null) return NormalizedBoardCardFilter.Invalid(labelError);

            var keyword = request.Keyword?.Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(keyword))
                keyword = null;

            return new NormalizedBoardCardFilter(
                keyword,
                request.NoMembers,
                request.AssignedToMe,
                memberUIds,
                completionStatus,
                dueDateFilters,
                request.NoLabels,
                labelGroups,
                matchMode,
                null);
        }

        private static List<string> NormalizeIds(IEnumerable<string>? ids, out string? errorMessage)
        {
            errorMessage = null;
            var normalized = new List<string>();
            if (ids == null) return normalized;

            foreach (var id in ids)
            {
                var trimmed = id?.Trim();
                if (string.IsNullOrWhiteSpace(trimmed))
                {
                    errorMessage = "Identifier filter khÃ´ng há»£p lá»‡.";
                    return new List<string>();
                }

                if (!normalized.Contains(trimmed))
                    normalized.Add(trimmed);
            }

            return normalized;
        }

        private static List<List<string>> NormalizeLabelGroups(
            IEnumerable<string>? legacyLabelUIds,
            IEnumerable<BoardCardLabelFilterGroupRequest>? selectedLabelGroups,
            out string? errorMessage)
        {
            errorMessage = null;
            var normalizedGroups = new List<List<string>>();

            var legacyIds = NormalizeIds(legacyLabelUIds, out var legacyError);
            if (legacyError != null)
            {
                errorMessage = legacyError;
                return new List<List<string>>();
            }

            normalizedGroups.AddRange(legacyIds.Select(id => new List<string> { id }));

            if (selectedLabelGroups == null)
                return normalizedGroups;

            foreach (var group in selectedLabelGroups)
            {
                if (group == null)
                {
                    errorMessage = "Label group filter khÃƒÂ´ng hÃ¡Â»Â£p lÃ¡Â»â€¡.";
                    return new List<List<string>>();
                }

                var ids = NormalizeIds(group.CardLabelUIds, out var groupError);
                if (groupError != null)
                {
                    errorMessage = groupError;
                    return new List<List<string>>();
                }

                if (ids.Count == 0)
                {
                    errorMessage = "Label group filter khÃƒÂ´ng hÃ¡Â»Â£p lÃ¡Â»â€¡.";
                    return new List<List<string>>();
                }

                normalizedGroups.Add(ids);
            }

            return normalizedGroups;
        }

        private sealed record NormalizedBoardCardFilter(
            string? Keyword,
            bool NoMembers,
            bool AssignedToMe,
            List<string> MemberUIds,
            string? CompletionStatus,
            List<string> DueDateFilters,
            bool NoLabels,
            List<List<string>> LabelGroups,
            string MatchMode,
            string? ErrorMessage)
        {
            public bool HasAnyPredicate =>
                Keyword != null ||
                NoMembers ||
                AssignedToMe ||
                MemberUIds.Count > 0 ||
                CompletionStatus != null ||
                DueDateFilters.Count > 0 ||
                NoLabels ||
                LabelGroups.Count > 0;

            public static NormalizedBoardCardFilter Invalid(string message) =>
                new(null, false, false, new List<string>(), null, new List<string>(), false, new List<List<string>>(), BoardCardFilterValues.MatchExact, message);
        }

        public async Task<bool> UpdateCard(Card card, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(card.CardUId, userUId))
                    return false;

                var existing = await _dbContext.Todos.FindAsync(card.CardUId);
                if (existing == null) return false;
                if (CardStatusValues.IsDueDateInPast(card.DueDate))
                    return false;

                var dueDateChanged = existing.DueDate != card.DueDate;
                var oldTitle = existing.Title ?? existing.CardUId;
                var newTitle = card.Title ?? card.CardUId;
                var titleChanged = oldTitle != newTitle;
                var oldListUId = existing.ListUId;
                var moved = oldListUId != card.ListUId && !string.IsNullOrWhiteSpace(card.ListUId);
                existing.Title = card.Title;
                existing.Description = card.Description;
                existing.DueDate = card.DueDate;
                existing.Position = card.Position;
                existing.ListUId = card.ListUId;
                existing.BackgroundUrl = card.BackgroundUrl;
                CardStatusValues.ApplyCalculatedStatus(existing);
                _dbContext.Update(existing);
                await _dbContext.SaveChangesAsync();
                if (dueDateChanged)
                {
                    await _dueDateReminderService.ResetReminderHistoryAsync(existing.CardUId);
                }
                if (titleChanged)
                {
                    var actorName = await GetUserDisplayNameAsync(userUId);
                    var boardId = await GetBoardIdForListAsync(existing.ListUId);
                    var notifications = await BuildCardMemberNotificationsAsync(
                        existing.CardUId,
                        userUId,
                        NotificationType.CardRenamed,
                        "Thẻ đã được đổi tên",
                        $"{actorName} đã đổi tên {oldTitle} thành {newTitle}.",
                        boardId,
                        existing.ListUId);

                    await _notificationService.TryCreateManyInternalAsync(notifications, "card rename");
                }
                if (moved)
                {
                    var destinationList = await _dbContext.Lists
                        .AsNoTracking()
                        .FirstOrDefaultAsync(l => l.ListUId == existing.ListUId);
                    if (destinationList != null)
                    {
                        var actorName = await GetUserDisplayNameAsync(userUId);
                        var notifications = await BuildCardMemberNotificationsAsync(
                            existing.CardUId,
                            userUId,
                            NotificationType.Move,
                            "Thẻ đã được di chuyển",
                            $"{actorName} đã chuyển {newTitle} sang {destinationList.ListName}.",
                            destinationList.BoardUId,
                            existing.ListUId);

                        await _notificationService.TryCreateManyInternalAsync(notifications, "card move");
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật Card: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateListUid(string cardUId, string? newListUId, string userUId, int? position = null)
        {
            if (!await _authService.CanEditCardAsync(cardUId, userUId))
                return false;

            using var transaction = await _dbContext.Database.BeginTransactionAsync();
            try
            {
                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;
                var oldListUId = card.ListUId;
                var destinationList = await _dbContext.Lists
                    .AsNoTracking()
                    .FirstOrDefaultAsync(l => l.ListUId == newListUId);
                var moved = oldListUId != newListUId && destinationList != null;
                card.ListUId = newListUId;
                if (position.HasValue) card.Position = position.Value;
                await _dbContext.SaveChangesAsync();
                if(newListUId == null)
                {
                    var exists = await _dbContext.UserInboxCards
                        .AnyAsync(u => u.CardUId == cardUId && u.UserUId == userUId);
                    if(!exists)
                    {
                        UserInboxCard userInboxCard = new UserInboxCard
                        {
                            UserUId = userUId,
                            CardUId = cardUId,
                        };
                        _dbContext.UserInboxCards.Add(userInboxCard);
                        await _dbContext.SaveChangesAsync();
                    }

                }else
                {
                    var userInbox = await _dbContext.UserInboxCards.FirstOrDefaultAsync(u => u.CardUId == cardUId);
                    if (userInbox != null)
                    {
                        _dbContext.UserInboxCards.Remove(userInbox);
                        await _dbContext.SaveChangesAsync();
                    }
                }

                await transaction.CommitAsync();
                if (moved)
                {
                    var actorName = await GetUserDisplayNameAsync(userUId);
                    var cardTitle = card.Title ?? card.CardUId;
                    var notifications = await BuildCardMemberNotificationsAsync(
                        cardUId,
                        userUId,
                        NotificationType.Move,
                        "Thẻ đã được di chuyển",
                        $"{actorName} đã chuyển {cardTitle} sang {destinationList!.ListName}.",
                        destinationList.BoardUId,
                        newListUId);

                    await _notificationService.TryCreateManyInternalAsync(notifications, "card move");
                }
                return true;
            }catch(Exception e)
            {
                await transaction.RollbackAsync();
                Console.WriteLine($"Lỗi khi cập nhật ListUId cho Card: {e.Message}");
                return false;
            }

        }

        public async Task<string?> UpdateStatus(string cardUId, string newStatus, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(cardUId, userUId))
                    return null;

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return null;

                var normalizedStatus = CardStatusValues.Normalize(newStatus);
                card.Status = normalizedStatus == CardStatusValues.Completed
                    ? CardStatusValues.Completed
                    : CardStatusValues.CalculateOpenStatus(card.DueDate, DateTime.UtcNow);

                _dbContext.Update(card);
                await _dbContext.SaveChangesAsync();

                Console.WriteLine($"Status updated successfully");

                return card.Status;
            }
            catch (Exception e)
            {
                Console.WriteLine($"Lỗi khi cập nhật Status cho Card: {e.Message}");
                return null;
            }
        }

        public async Task<(FileUrl? FileUrl, bool IsDuplicate)> AddFileToCardAsync(string cardUId, string url, string fileName, string userUId, string? description = null)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(cardUId, userUId))
                    return (null, false);

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return (null, false);

                // Check for duplicate URL
                var exists = await _dbContext.FileUrls
                    .AnyAsync(f => f.CardUId == cardUId && f.Url == url);
                if (exists) return (null, true);

                var fileUrl = new FileUrl
                {
                    CardUId = cardUId,
                    Url = url,
                    FileName = fileName,
                    Description = description,
                    CreatedAt = DateTime.UtcNow
                };

                _dbContext.FileUrls.Add(fileUrl);
                await _dbContext.SaveChangesAsync();

                var actorName = await GetUserDisplayNameAsync(userUId);
                var fileDisplayName = GetAttachmentDisplayName(fileUrl.FileName, fileUrl.Url);
                var cardTitle = card.Title ?? card.CardUId;
                var boardId = await GetBoardIdForListAsync(card.ListUId);
                var notifications = await BuildCardMemberNotificationsAsync(
                    cardUId,
                    userUId,
                    NotificationType.AttachmentAdded,
                    "Đính kèm đã được thêm",
                    $"{actorName} đã thêm một đính kèm {fileDisplayName} vào {cardTitle}.",
                    boardId,
                    card.ListUId);

                await _notificationService.TryCreateManyInternalAsync(notifications, "card attachment add");

                return (fileUrl, false);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm file vào Card: {ex.Message}");
                return (null, false);
            }
        }

        public async Task<List<FileUrl>> GetAttachmentsByCardAsync(string cardUId)
        {
            try
            {
                return await _dbContext.FileUrls
                    .Where(f => f.CardUId == cardUId)
                    .OrderByDescending(f => f.CreatedAt)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi lấy attachments: {ex.Message}");
                return new List<FileUrl>();
            }
        }

        public async Task<bool> DeleteAttachmentAsync(string fileUId, string userUId)
        {
            try
            {
                var fileUrl = await _dbContext.FileUrls
                    .Include(f => f.Card)
                    .FirstOrDefaultAsync(f => f.FileUId == fileUId);
                if (fileUrl == null) return false;

                if (!await _authService.CanEditCardAsync(fileUrl.CardUId, userUId))
                    return false;

                var fileDisplayName = GetAttachmentDisplayName(fileUrl.FileName, fileUrl.Url);
                var cardTitle = fileUrl.Card?.Title ?? fileUrl.CardUId;
                var listId = fileUrl.Card?.ListUId;
                var boardId = await GetBoardIdForListAsync(listId);
                _dbContext.FileUrls.Remove(fileUrl);
                await _dbContext.SaveChangesAsync();
                var actorName = await GetUserDisplayNameAsync(userUId);
                var notifications = await BuildCardMemberNotificationsAsync(
                    fileUrl.CardUId,
                    userUId,
                    NotificationType.AttachmentRemoved,
                    "Đính kèm đã bị xóa",
                    $"{actorName} đã xóa một đính kèm {fileDisplayName} khỏi {cardTitle}.",
                    boardId,
                    listId);

                await _notificationService.TryCreateManyInternalAsync(notifications, "card attachment remove");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi xóa attachment: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateAttachmentDescriptionAsync(string fileUId, string userUId, string? description)
        {
            try
            {
                var file = await _dbContext.FileUrls
                    .Include(f => f.Card)
                    .FirstOrDefaultAsync(f => f.FileUId == fileUId);
                if (file == null) return false;

                if (!await _authService.CanEditCardAsync(file.CardUId, userUId))
                    return false;

                file.Description = description;
                _dbContext.FileUrls.Update(file);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật mô tả attachment: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateDueDateAsync(string cardUId, DateTime? dueDate, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(cardUId, userUId))
                    return false;

                var card = await _dbContext.Todos
                    .Include(c => c.List)
                    .Include(c => c.CardMembers)
                    .FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                if (CardStatusValues.IsDueDateInPast(dueDate))
                    return false;

                var dueDateChanged = card.DueDate != dueDate;
                card.DueDate = dueDate;
                CardStatusValues.ApplyCalculatedStatus(card);
                _dbContext.Todos.Update(card);
                await _dbContext.SaveChangesAsync();
                if (dueDateChanged)
                {
                    await _dueDateReminderService.ResetReminderHistoryAsync(cardUId);
                }

                var actorName = await GetUserDisplayNameAsync(userUId);
                var cardTitle = card.Title ?? card.CardUId;
                var dueDateMessage = dueDate.HasValue
                    ? $"{actorName} đã đổi hạn của {cardTitle} thành {dueDate.Value:yyyy-MM-dd HH:mm}."
                    : $"{actorName} đã xóa hạn của {cardTitle}.";

                var assignees = card.CardMembers?
                    .Where(cm => cm.UserUId != userUId)
                    .Select(cm => cm.UserUId)
                    .Distinct()
                    .Select(recipientId => new NotificationDTO
                    {
                        RecipientId = recipientId,
                        ActorId = userUId,
                        Type = NotificationType.DueDateChanged,
                        Title = "Hạn thẻ đã thay đổi",
                        Message = dueDateMessage,
                        BoardId = card.List?.BoardUId,
                        ListId = card.ListUId,
                        CardId = cardUId,
                        Link = $"/card-detail/{cardUId}"
                    })
                    .ToList() ?? new List<NotificationDTO>();

                await _notificationService.TryCreateManyInternalAsync(assignees, "card due date update");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật ngày hết hạn: {ex.Message}");
                return false;
            }
        }
        public async Task<bool> ArchiveCardAsync(string cardUId, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(cardUId, userUId))
                    return false;

                var card = await _dbContext.Todos
                    .Include(c => c.List)
                    .FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                card.IsArchived = true;
                _dbContext.Todos.Update(card);
                await _dbContext.SaveChangesAsync();
                var actorName = await GetUserDisplayNameAsync(userUId);
                var cardTitle = card.Title ?? card.CardUId;
                var notifications = await BuildCardMemberNotificationsAsync(
                    cardUId,
                    userUId,
                    NotificationType.CardArchived,
                    "Thẻ đã được lưu trữ",
                    $"{actorName} đã lưu trữ {cardTitle}",
                    card.List?.BoardUId,
                    card.ListUId);

                await _notificationService.TryCreateManyInternalAsync(notifications, "card archive");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi lưu trữ Card: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UnarchiveCardAsync(string cardUId, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(cardUId, userUId))
                    return false;

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                card.IsArchived = false;
                _dbContext.Todos.Update(card);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi khôi phục Card: {ex.Message}");
                return false;
            }
        }

        public async Task<List<Card>> GetArchivedCardsByBoardAsync(string boardUId, string userUId)
        {
            return await _dbContext.Todos
                .Where(c => c.IsArchived && c.List != null && c.List.BoardUId == boardUId)
                .Include(c => c.List)
                .Include(c => c.CardLabels)
                .Include(c => c.CardMembers).ThenInclude(m => m.User)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();
        }

        public async Task<int> ArchiveAllCompletedCardsAsync(string boardUId, string userUId)
        {
            try
            {
                // Allow only admin/owner of the board
                var isBoardAdmin = await _dbContext.BoardMembers
                    .AnyAsync(bm => bm.BoardUId == boardUId && bm.UserUId == userUId &&
                              (bm.BoardRole == "Owner" || bm.BoardRole == "Admin"));
                if (!isBoardAdmin) return 0;

                var cards = await _dbContext.Todos
                    .Where(c => !c.IsArchived &&
                                c.List != null &&
                                c.List.BoardUId == boardUId)
                    .ToListAsync();

                cards = cards
                    .Where(c => CardStatusValues.IsCompleted(c.Status))
                    .ToList();

                foreach (var c in cards)
                    c.IsArchived = true;

                await _dbContext.SaveChangesAsync();
                return cards.Count;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi lưu trữ hàng loạt: {ex.Message}");
                return 0;
            }
        }

        public async Task<bool> JoinCardAsync(string cardUId, string userUId, string boardId)
        {
            try
            {
                // Check board allows member join
                var board = await _dbContext.Boards.FindAsync(boardId);
                if (board == null || !board.AllowMemberJoinCard) return false;

                // Check user is a board member
                var isBoardMember = await _dbContext.BoardMembers
                    .AnyAsync(bm => bm.BoardUId == boardId && bm.UserUId == userUId);
                if (!isBoardMember) return false;

                var card = await _dbContext.Todos.FindAsync(cardUId);
                if (card == null) return false;

                var alreadyMember = await _dbContext.CardMembers
                    .AnyAsync(cm => cm.CardUId == cardUId && cm.UserUId == userUId);
                if (alreadyMember) return true;

                _dbContext.CardMembers.Add(new CardMember
                {
                    CardMemberUId = Guid.NewGuid().ToString(),
                    CardUId = cardUId,
                    UserUId = userUId,
                    Role = "Assignee",
                    AssignedAt = DateTime.UtcNow,
                });
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi tham gia Card: {ex.Message}");
                return false;
            }
        }

        private async Task<List<NotificationDTO>> BuildCardMemberNotificationsAsync(
            string cardUId,
            string actorUId,
            NotificationType type,
            string title,
            string message,
            string? boardId,
            string? listId)
        {
            var recipients = await _dbContext.CardMembers
                .AsNoTracking()
                .Where(cm => cm.CardUId == cardUId && cm.UserUId != actorUId)
                .Select(cm => cm.UserUId)
                .Distinct()
                .ToListAsync();

            return recipients.Select(recipientId => new NotificationDTO
            {
                RecipientId = recipientId,
                ActorId = actorUId,
                Type = type,
                Title = title,
                Message = message,
                BoardId = boardId,
                ListId = listId,
                CardId = cardUId,
                Link = $"/card-detail/{cardUId}"
            }).ToList();
        }

        private async Task<string> GetUserDisplayNameAsync(string userUId)
        {
            var name = await _dbContext.Users
                .AsNoTracking()
                .Where(u => u.UserUId == userUId)
                .Select(u => u.UserName)
                .FirstOrDefaultAsync();

            return string.IsNullOrWhiteSpace(name) ? userUId : name;
        }

        private async Task<string?> GetBoardIdForListAsync(string? listUId)
        {
            if (string.IsNullOrWhiteSpace(listUId))
                return null;

            return await _dbContext.Lists
                .AsNoTracking()
                .Where(l => l.ListUId == listUId)
                .Select(l => l.BoardUId)
                .FirstOrDefaultAsync();
        }

        private static string GetAttachmentDisplayName(string? fileName, string? url)
        {
            if (!string.IsNullOrWhiteSpace(fileName))
                return fileName;

            return string.IsNullOrWhiteSpace(url) ? "tệp đính kèm" : url;
        }
    }
}
