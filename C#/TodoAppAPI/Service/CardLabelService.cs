using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public class CardLabelService : ICardLabelService
    {
        private readonly Data.TodoDbContext _context;

        public CardLabelService(Data.TodoDbContext context)
        {
            _context = context;
        }

        public async Task<CardLabelDto> AddLabelAsync(string cardId, CreateCardLabelRequest request)
        {
            var label = new CardLabel
            {
                CardUId = cardId,
                Title = request.Title,
                ColorCode = request.ColorCode
            };

            await _context.CardLabels.AddAsync(label);
            await _context.SaveChangesAsync();

            return new CardLabelDto
            {
                CardLabelUId = label.CardLabelUId,
                Title = label.Title,
                ColorCode = label.ColorCode
            };
        }

        public async Task<bool> UpdateLabelAsync(string labelId, UpdateCardLabelRequest request)
        {
            var label = await _context.CardLabels.FindAsync(labelId);
            if (label == null) return false;

            label.Title = request.Title;
            label.ColorCode = request.ColorCode;
            label.UpdatedAt = DateTime.UtcNow;

            _context.CardLabels.Update(label);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DeleteLabelAsync(string labelId)
        {
            var label = await _context.CardLabels.FindAsync(labelId);
            if (label == null) return false;

            _context.CardLabels.Remove(label);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
