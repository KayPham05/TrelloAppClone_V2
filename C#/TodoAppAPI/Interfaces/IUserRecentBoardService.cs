using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IUserRecentBoardService
    {
        Task<List<Board>> GetRecentBoardByUserUId(string userUId);
        Task<bool> SaveRecentBoard(string userUId, string boardUId);
    }
}
