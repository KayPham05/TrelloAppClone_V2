using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IActivity
    {
        Task <bool> AddActivity(string userUId, string action);
        Task<List<ActivityDto>> GetActivities(int limit = 10, int offset = 0);
        Task<List<ActivityDto>> GetActivitiesByUserUId(string userUId, int limit = 50);
        Task<int> GetTotalCount();
        //Task<List<ActivityDto>> GetActivitiesByBoardUId(string boardUId, int limit = 50);
    }
}
