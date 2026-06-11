using Microsoft.EntityFrameworkCore;
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

                _dbContext.FileUrls.Remove(fileUrl);
                await _dbContext.SaveChangesAsync();
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

                var assignees = card.CardMembers?
                    .Where(cm => cm.UserUId != userUId)
                    .Select(cm => cm.UserUId)
                    .Distinct()
                    .Select(recipientId => new NotificationDTO
                    {
                        RecipientId = recipientId,
                        ActorId = userUId,
                        Type = NotificationType.DueDateChanged,
                        Title = "Card due date changed",
                        Message = dueDate.HasValue
                            ? $"Due date for card '{card.Title ?? card.CardUId}' is now {dueDate.Value:yyyy-MM-dd}."
                            : $"Due date was removed from card '{card.Title ?? card.CardUId}'.",
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

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                card.IsArchived = true;
                _dbContext.Todos.Update(card);
                await _dbContext.SaveChangesAsync();
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
    }
}
