using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface IPlannerService
    {
        Task<Dictionary<string, List<CardDTO>>> GetPlannerCardsAsync(string userUId, DateTime from, DateTime to);
    }
}
