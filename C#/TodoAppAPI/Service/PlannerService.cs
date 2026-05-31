using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Service
{
    public class PlannerService : IPlannerService
    {
        private readonly TodoDbContext _dbContext;

        public PlannerService(TodoDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<Dictionary<string, List<CardDTO>>> GetPlannerCardsAsync(string userUId, DateTime from, DateTime to)
        {
            var cards = await _dbContext.CardMembers
                .Where(cm => cm.UserUId == userUId && cm.Card.DueDate != null && cm.Card.DueDate >= from && cm.Card.DueDate <= to && cm.Card.Status != "Deleted")
                .Include(cm => cm.Card)
                .ThenInclude(c => c.CardLabels)
                .Select(cm => cm.Card)
                .ToListAsync();

            var result = cards
                .Where(c => c.DueDate.HasValue)
                .GroupBy(c => c.DueDate.Value.Date.ToString("yyyy-MM-dd"))
                .ToDictionary(
                    g => g.Key,
                    g => g.Select(c => new CardDTO
                    {
                        CardUId = c.CardUId,
                        Title = c.Title ?? "",
                        Description = c.Description,
                        DueDate = c.DueDate,
                        Position = c.Position,
                        CreatedAt = c.CreatedAt,
                        Status = c.Status ?? "",
                        BackgroundUrl = c.BackgroundUrl,
                        ListUId = c.ListUId,
                        CardLabels = c.CardLabels != null ? c.CardLabels.Select(cl => new CardLabelDto 
                        {
                            CardLabelUId = cl.CardLabelUId,
                            Title = cl.Title,
                            ColorCode = cl.ColorCode
                        }).ToList() : new List<CardLabelDto>()
                    }).ToList()
                );

            return result;
        }
    }
}
