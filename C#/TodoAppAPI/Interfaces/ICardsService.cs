using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface ICardsService
    {
        List<Card> GetCardsByBoardId(string boardUId);
        Task<BoardCardFilterResult> FilterCardsByBoardAsync(string boardUId, BoardCardFilterRequest request, string userUId);
        Task<bool> AddCard(Card card);
        Task<bool> UpdateCard(Card card, string userUId);
        Task<bool> DeleteCard(string Uid, string userUId);
        Card? GetById(string cardUId);
        Task<bool> UpdateListUid(string cardUId, string? newListUId, string userUId, int? position = null);
        Task<string?> UpdateStatus(string cardUId, string newStatus, string userUId);
        Task<(FileUrl? FileUrl, bool IsDuplicate)> AddFileToCardAsync(string cardUId, string url, string fileName, string userUId, string? description = null);
        Task<List<FileUrl>> GetAttachmentsByCardAsync(string cardUId);
        Task<bool> DeleteAttachmentAsync(string fileUId, string userUId);
        Task<bool> UpdateAttachmentDescriptionAsync(string fileUId, string userUId, string? description);
        Task<bool> UpdateAttachmentNameAsync(string fileUId, string userUId, string fileName);
        Task<bool> UpdateDueDateAsync(string cardUId, DateTime? dueDate, string userUId);

        // Archive
        Task<bool> ArchiveCardAsync(string cardUId, string userUId);
        Task<bool> UnarchiveCardAsync(string cardUId, string userUId);
        Task<List<Card>> GetArchivedCardsByBoardAsync(string boardUId, string userUId);
        Task<int> ArchiveAllCompletedCardsAsync(string boardUId, string userUId);

        // Join card
        Task<bool> JoinCardAsync(string cardUId, string userUId, string boardId);
    }
}
