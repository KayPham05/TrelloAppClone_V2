using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IListService
    {
        Task<List<ListDTO>> GetAllListsByBoardUidAsync(string boardUId);
        Task<List> GetListByIdAsync(string listUId);
        Task<List> AddListAsync(List list);
        Task<bool> UpdateListAsync(List list);
        Task<bool> DeleteListAsync(string listUId);
        Task<bool> UpdateStatus(List list);
        Task<bool> UpdateListPositionAsync(string boardUId, List<List> newOrder);
    }
}
