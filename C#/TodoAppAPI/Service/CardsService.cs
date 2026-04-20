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
        public CardsService(TodoDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public bool AddCard(Card card)
        {
            try
            {
                card.CardUId = Guid.NewGuid().ToString();

                if (string.IsNullOrEmpty(card.ListUId))
                    card.ListUId = null; // Inbox mặc định (null)

                _dbContext.Todos.Add(card);
                _dbContext.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm Card: {ex.Message}");
                return false;
            }
        }

        public bool DeleteCard(string cardUId)
        {
            try
            {
                var card = _dbContext.Todos.FirstOrDefault(c => c.CardUId == cardUId);
                if (card == null) return false;

                _dbContext.Todos.Remove(card);
                _dbContext.SaveChanges();
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
                .FirstOrDefault(c => c.CardUId == cardUId);
        }

        public List<Card> GetCardsByBoardId(string boardUId)
        {
            return _dbContext.Todos
                .Include(c => c.List)
                .Where(c => c.Status != "Deleted" && c.List.BoardUId == boardUId)
                .ToList();
        }

        public bool UpdateCard(Card card)
        {
            try
            {
                var existing = _dbContext.Todos.Find(card.CardUId);
                if (existing == null) return false;
                existing.Title = card.Title;
                existing.Description = card.Description;
                existing.DueDate = card.DueDate;
                existing.Position = card.Position;
                existing.ListUId = card.ListUId;
                existing.BackgroundUrl = card.BackgroundUrl;
                _dbContext.Update(existing);
                _dbContext.SaveChanges();
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

        public async Task<bool> UpdateStatus(string cardUId, string newStatus)
        {
            try
            {
                var card = _dbContext.Todos.FirstOrDefault(c => c.CardUId == cardUId);
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

        public async Task<CardDTO?> AddCardToInboxAsync(string userUId, Card card)
        {
            using var transaction = await _dbContext.Database.BeginTransactionAsync();
            try
            {
                card.CardUId = Guid.NewGuid().ToString();
                
                if (string.IsNullOrEmpty(card.ListUId))
                    card.ListUId = null; // Inbox mặc định không có list
                    
                card.CreatedAt = DateTime.UtcNow;

                _dbContext.Todos.Add(card);
                
                UserInboxCard userInboxCard = new UserInboxCard
                {
                    UserUId = userUId,
                    CardUId = card.CardUId,
                    AddedAt = DateTime.UtcNow
                };
                
                _dbContext.UserInboxCards.Add(userInboxCard);
                
                await _dbContext.SaveChangesAsync();
                await transaction.CommitAsync();
                
                return new CardDTO {
                    CardUId = card.CardUId,
                    Title = card.Title,
                    Description = card.Description,
                    DueDate = card.DueDate,
                    Position = card.Position,
                    CreatedAt = card.CreatedAt,
                    Status = card.Status,
                    ListUId = card.ListUId,
                    BackgroundUrl = card.BackgroundUrl
                };
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                Console.WriteLine($"Lỗi khi thêm Card vào Inbox: {ex.Message}");
                return null;
            }
        }

        public async Task<(FileUrl? FileUrl, bool IsDuplicate)> AddFileToCardAsync(string cardUId, string url, string fileName, string? description = null)
        {
            try
            {
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

        public async Task<bool> DeleteAttachmentAsync(string fileUId)
        {
            try
            {
                var fileUrl = await _dbContext.FileUrls.FirstOrDefaultAsync(f => f.FileUId == fileUId);
                if (fileUrl == null) return false;

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

        public async Task<bool> UpdateAttachmentDescriptionAsync(string fileUId, string? description)
        {
            try
            {
                var file = await _dbContext.FileUrls.FirstOrDefaultAsync(f => f.FileUId == fileUId);
                if (file == null) return false;

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
    }
}
