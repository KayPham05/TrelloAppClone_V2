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
            var cards = await _dbContext.Todos
                .Where(c => c.DueDate != null && c.DueDate >= from && c.DueDate <= to && c.Status != "Deleted" && !c.IsArchived)
                .Where(c => 
                    c.UserUId == userUId || 
                    _dbContext.CardMembers.Any(cm => cm.CardUId == c.CardUId && cm.UserUId == userUId) ||
                    _dbContext.UserInboxCards.Any(uic => uic.CardUId == c.CardUId && uic.UserUId == userUId)
                )
                .Include(c => c.CardLabels)
                .Include(c => c.CardMembers!)
                    .ThenInclude(cm => cm.User)
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
                        }).ToList() : new List<CardLabelDto>(),
                        Members = c.CardMembers != null ? c.CardMembers.Select(cm => new CardMemberDto
                        {
                            CardMemberUId = cm.CardMemberUId,
                            CardUId = cm.CardUId,
                            UserUId = cm.UserUId,
                            Role = cm.Role,
                            AssignedAt = cm.AssignedAt,
                            User = cm.User != null ? new UserDto
                            {
                                UserUId = cm.User.UserUId,
                                Name = cm.User.UserName,
                                Email = cm.User.Email
                            } : null
                        }).ToList() : new List<CardMemberDto>()
                    }).ToList()
                );

            return result;
        }
    }
}
