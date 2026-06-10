using System.Threading.Tasks;
using TodoAppAPI.DTOs.Search;

namespace TodoAppAPI.Interfaces
{
    public interface ISearchService
    {
        Task<SearchResultDTO> SearchBoardsAndCardsAsync(string query, string userUId);
    }
}
