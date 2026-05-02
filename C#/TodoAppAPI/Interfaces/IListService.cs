using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IListService
    {
        Task<List<ListDTO>> GetAllListsByBoardUidAsync(string boardUId);
        Task<List> GetListByIdAsync(string listUId);
        Task<List?> AddListAsync(List list, string userUId);
        Task<bool> UpdateListAsync(List list, string userUId);
        Task<bool> DeleteListAsync(string listUId, string userUId);
        Task<bool> UpdateStatus(List list, string userUId);
        Task<bool> UpdateListPositionAsync(string boardUId, List<List> newOrder, string userUId);
    }
}
