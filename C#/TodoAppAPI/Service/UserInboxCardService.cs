using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

using TodoAppAPI.DTOs;

namespace TodoAppAPI.Service
{
    public class UserInboxCardService : IUserInboxCard
    {
        private readonly TodoDbContext _context;
        public UserInboxCardService(TodoDbContext context)
        {
            _context = context;
        }
        public async Task<bool> AddCardInbox(string userUId, string cardUId)
        {
            try
            {
                // Gán position = max + 1
                var maxPos = await _context.UserInboxCards
                    .Where(u => u.UserUId == userUId)
                    .MaxAsync(u => (int?)u.Position) ?? -1;

                UserInboxCard userInboxCard = new UserInboxCard
                {
                    UserUId = userUId,
                    CardUId = cardUId,
                    AddedAt = DateTime.UtcNow,
                    Position = maxPos + 1
                };
                _context.UserInboxCards.Add(userInboxCard);
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm Card vào Inbox: {ex.Message}");
                return false;
            }
        }

        public async Task<CardDTO?> AddCardToInboxAsync(string userUId, Card card)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                card.CardUId = Guid.NewGuid().ToString();
                card.UserUId = userUId;
                
                if (string.IsNullOrEmpty(card.ListUId))
                    card.ListUId = null; // Inbox mặc định không có list
                    
                card.CreatedAt = DateTime.UtcNow;

                _context.Todos.Add(card);

                // Gán position = max + 1
                var maxPos = await _context.UserInboxCards
                    .Where(u => u.UserUId == userUId)
                    .MaxAsync(u => (int?)u.Position) ?? -1;

                UserInboxCard userInboxCard = new UserInboxCard
                {
                    UserUId = userUId,
                    CardUId = card.CardUId,
                    AddedAt = DateTime.UtcNow,
                    Position = maxPos + 1
                };
                
                _context.UserInboxCards.Add(userInboxCard);
                
                await _context.SaveChangesAsync();
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

        public async Task<List<CardDTO>> GetCardInbox(string userUId)
        {
            var cards = await _context.UserInboxCards
                            .Where(uic => uic.UserUId == userUId)
                            .OrderBy(uic => uic.Position)
                            .Include(uic => uic.Card)
                                .ThenInclude(c => c.CardLabels)
                            .Select(uic => new CardDTO {
                                CardUId = uic.Card.CardUId,
                                Title = uic.Card.Title,
                                Description = uic.Card.Description,
                                DueDate = uic.Card.DueDate,
                                Position = uic.Position,   // dùng Position từ UserInboxCard
                                CreatedAt = uic.Card.CreatedAt,
                                Status = uic.Card.Status,
                                ListUId = uic.Card.ListUId,
                                BackgroundUrl = uic.Card.BackgroundUrl,
                                CardLabels = uic.Card.CardLabels.Select(l => new CardLabelDto {
                                    CardLabelUId = l.CardLabelUId,
                                    Title = l.Title,
                                    ColorCode = l.ColorCode
                                }).ToList()
                            }).ToListAsync();
            return cards;
        }

        public async Task<bool> UpdateInboxCardAsync(string cardId, string userId, Card card)
        {
            try
            {
                // Dedicated inbox permission check: user must own the card in UserInboxCards
                var isOwner = await _context.UserInboxCards
                    .AnyAsync(u => u.CardUId == cardId && u.UserUId == userId);

                if (!isOwner) return false;

                var existingCard = await _context.Todos.FirstOrDefaultAsync(c => c.CardUId == cardId);
                if (existingCard == null) return false;

                // Update allowed inbox fields
                if (card.Title != null) existingCard.Title = card.Title;
                existingCard.Description = card.Description;
                existingCard.DueDate = card.DueDate;
                existingCard.BackgroundUrl = card.BackgroundUrl;
                if (card.Status != null) existingCard.Status = card.Status;
                existingCard.Position = card.Position;

                _context.Todos.Update(existingCard);
                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật card inbox: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Di chuyển card từ board sang inbox tại vị trí cụ thể.
        /// Sẽ set card.ListUId = null và chèn UserInboxCard tại đúng position.
        /// </summary>
        public async Task<bool> MoveCardToInboxAsync(string cardId, string userUId, int position)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Tách card khỏi board list
                var card = await _context.Todos.FirstOrDefaultAsync(c => c.CardUId == cardId);
                if (card == null) return false;
                card.ListUId = null;
                _context.Todos.Update(card);

                // 2. Kiểm tra nếu đã có trong inbox → chỉ cập nhật position
                var existing = await _context.UserInboxCards
                    .FirstOrDefaultAsync(u => u.CardUId == cardId && u.UserUId == userUId);

                if (existing != null)
                {
                    // Shift các card khác để nhường chỗ
                    var toShift = await _context.UserInboxCards
                        .Where(u => u.UserUId == userUId && u.CardUId != cardId && u.Position >= position)
                        .ToListAsync();
                    foreach (var item in toShift) item.Position++;
                    existing.Position = position;
                }
                else
                {
                    // 3. Shift các card từ position trở đi lên +1
                    var toShift = await _context.UserInboxCards
                        .Where(u => u.UserUId == userUId && u.Position >= position)
                        .ToListAsync();
                    foreach (var item in toShift) item.Position++;

                    // 4. Insert UserInboxCard mới
                    _context.UserInboxCards.Add(new UserInboxCard
                    {
                        UserUId = userUId,
                        CardUId = cardId,
                        AddedAt = DateTime.UtcNow,
                        Position = position
                    });
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                Console.WriteLine($"Lỗi MoveCardToInbox: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Bulk update thứ tự các card trong inbox sau khi kéo-thả.
        /// </summary>
        public async Task<bool> ReorderInboxCardsAsync(string userUId, List<InboxReorderItem> items)
        {
            try
            {
                var cardIds = items.Select(i => i.CardUId).ToList();
                var inboxCards = await _context.UserInboxCards
                    .Where(u => u.UserUId == userUId && cardIds.Contains(u.CardUId))
                    .ToListAsync();

                foreach (var inboxCard in inboxCards)
                {
                    var item = items.FirstOrDefault(i => i.CardUId == inboxCard.CardUId);
                    if (item != null) inboxCard.Position = item.Position;
                }

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi ReorderInboxCards: {ex.Message}");
                return false;
            }
        }
    }
}
