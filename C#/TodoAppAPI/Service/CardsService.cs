using Microsoft.EntityFrameworkCore;
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

        public CardsService(TodoDbContext dbContext, IAuthorizationService authService)
        {
            _dbContext = dbContext;
            _authService = authService;
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
            return _dbContext.Todos
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.Comments)
                .Include(c => c.FileUrls)
                .Include(c => c.CardMembers)
                .Include(c => c.CardLabels)
                .FirstOrDefault(c => c.CardUId == cardUId);
        }

        public List<Card> GetCardsByBoardId(string boardUId)
        {
            return _dbContext.Todos
                .Include(c => c.List)
                .Include(c => c.TodoItems)
                .Include(c => c.Comments)
                .Include(c => c.FileUrls)
                .Include(c => c.CardMembers)
                .Include(c => c.CardLabels)
                .Where(c => c.Status != "Deleted" && c.List.BoardUId == boardUId)
                .ToList();
        }

        public async Task<bool> UpdateCard(Card card, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(card.CardUId, userUId))
                    return false;

                var existing = await _dbContext.Todos.FindAsync(card.CardUId);
                if (existing == null) return false;
                existing.Title = card.Title;
                existing.Description = card.Description;
                existing.DueDate = card.DueDate;
                existing.Position = card.Position;
                existing.ListUId = card.ListUId;
                existing.BackgroundUrl = card.BackgroundUrl;
                _dbContext.Update(existing);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật Card: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateListUid(string cardUId, string? newListUId, string userUId)
        {
            if (!await _authService.CanEditCardAsync(cardUId, userUId))
                return false;

            using var transaction = await _dbContext.Database.BeginTransactionAsync();
            try
            {
                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;
                card.ListUId = newListUId;
                _dbContext.Update(card);
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

        public async Task<bool> UpdateStatus(string cardUId, string newStatus, string userUId)
        {
            try
            {
                if (!await _authService.CanEditCardAsync(cardUId, userUId))
                    return false;

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                card.Status = newStatus;

                _dbContext.Update(card);
                await _dbContext.SaveChangesAsync();

                Console.WriteLine($"Status updated successfully");

                return true;
            }
            catch (Exception e)
            {
                Console.WriteLine($"Lỗi khi cập nhật Status cho Card: {e.Message}");
                return false;
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

                var card = await _dbContext.Todos.FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                card.DueDate = dueDate;
                _dbContext.Todos.Update(card);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật ngày hết hạn: {ex.Message}");
                return false;
            }
        }
    }
}
