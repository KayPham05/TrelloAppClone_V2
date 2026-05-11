using TodoAppAPI.Models;

using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface IUserRecentBoardService
    {
        Task<List<BoardDTO>> GetRecentBoardByUserUId(string userUId);
        Task<bool> SaveRecentBoard(string userUId, string boardUId);
    }
}
