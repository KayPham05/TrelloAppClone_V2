using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IBoardService
    {

        Task<List<BoardDTO>> GetAllBoardsByUserAsync(string userUId);
        Task<BoardDTO?> GetBoardByIdAsync(string boardUId);
        Task<Board?> AddBoardAsync(Board board);
        Task<bool> UpdateBoardAsync(Board board);
        Task<bool> DeleteBoardAsync(string boardUId);
        Task<BoardDTO?> GetBoardByNameAsync(string boardName);
    }
}
