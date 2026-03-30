using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class AddInboxCardService : IAddInboxCardService
    {
        private readonly TodoDbContext _context;

        public AddInboxCardService(TodoDbContext context)
        {
            _context = context;
        }
        public async Task<bool> AddCardToInbox(AddInboxCard addInboxCard)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {

                Card card = new Card
                {
                    CardUId = Guid.NewGuid().ToString(),
                    Title = addInboxCard.Card.Title,
                    CreatedAt = DateTime.Now
                };

                _context.Todos.Add(card);
                await _context.SaveChangesAsync();

                UserInboxCard userInboxCard = new UserInboxCard
                {
                    UserUId = addInboxCard.UserUId,
                    CardUId = card.CardUId,
                    AddedAt = DateTime.Now
                };

                _context.UserInboxCards.Add(userInboxCard);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();
                return true;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                Console.WriteLine($"Lỗi khi thêm Card vào Inbox: {ex.Message}");
                return false;



            }
        }
    }
}

