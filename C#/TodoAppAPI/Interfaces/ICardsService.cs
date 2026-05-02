using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface ICardsService
    {
        List<Card> GetCardsByBoardId(string boardUId);
        Task<bool> AddCard(Card todo);
        Task<bool> UpdateCard(Card card, string userUId);
        Task<bool> DeleteCard(string Uid, string userUId);
        Card? GetById(string cardUId);
        Task<bool> UpdateListUid(string cardUId, string? newListUId, string userUId);
        Task<bool> UpdateStatus(string cardUId, string newStatus, string userUId);
        Task<(FileUrl? FileUrl, bool IsDuplicate)> AddFileToCardAsync(string cardUId, string url, string fileName, string userUId, string? description = null);
        Task<List<FileUrl>> GetAttachmentsByCardAsync(string cardUId);
        Task<bool> DeleteAttachmentAsync(string fileUId, string userUId);
        Task<bool> UpdateAttachmentDescriptionAsync(string fileUId, string userUId, string? description);
        Task<bool> UpdateDueDateAsync(string cardUId, DateTime? dueDate, string userUId);
    }
}
