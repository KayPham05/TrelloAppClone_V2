using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface IUserStarredBoardService
    {
        Task<List<BoardDTO>> GetStarredBoardByUserUId(string userUId);
        Task<bool> SetStarredBoard(string userUId, string boardUId, bool isStarred);
    }
}
