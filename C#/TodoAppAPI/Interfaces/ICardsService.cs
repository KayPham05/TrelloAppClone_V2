using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface ICardsService
    {
        List<Card> GetCardsByBoardId(string boardUId);
        bool AddCard(Card todo);
        bool UpdateCard(Card card);
        bool DeleteCard(string Uid);
        Card? GetById(string cardUId);
        Task<bool> UpdateListUid(string cardUId, string? newListUId, string userUId);
        Task<bool> UpdateStatus(string cardUId, string newStatus);
        Task<CardDTO?> AddCardToInboxAsync(string userUId, Card card);
        Task<(FileUrl? FileUrl, bool IsDuplicate)> AddFileToCardAsync(string cardUId, string url, string fileName, string? description = null);
        Task<List<FileUrl>> GetAttachmentsByCardAsync(string cardUId);
        Task<bool> DeleteAttachmentAsync(string fileUId);
        Task<bool> UpdateAttachmentDescriptionAsync(string fileUId, string? description);
        Task<bool> UpdateDueDateAsync(string cardUId, DateTime? dueDate);
    }
}
