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
                UserInboxCard userInboxCard = new UserInboxCard
                {
                    UserUId = userUId,
                    CardUId = cardUId,
                    AddedAt = DateTime.UtcNow
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

        public async Task<List<CardDTO>> GetCardInbox(string userUId)
        {

            var cards = await _context.UserInboxCards
                            .Where(uic => uic.UserUId == userUId)
                            .Include(uic => uic.Card)
                            .Select(uic => new CardDTO {
                                CardUId = uic.Card.CardUId,
                                Title = uic.Card.Title,
                                Description = uic.Card.Description,
                                DueDate = uic.Card.DueDate,
                                Position = uic.Card.Position,
                                CreatedAt = uic.Card.CreatedAt,
                                Status = uic.Card.Status,
                                ListUId = uic.Card.ListUId,
                                BackgroundUrl = uic.Card.BackgroundUrl
                            }).ToListAsync();
            return cards;

        }
    }
}
