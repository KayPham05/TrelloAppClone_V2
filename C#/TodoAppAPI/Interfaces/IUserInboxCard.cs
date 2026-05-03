using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IUserInboxCard
    {
        Task<List<CardDTO>> GetCardInbox(string userUId);
        Task<bool> AddCardInbox(string userUId, string cardUId);
        Task<CardDTO?> AddCardToInboxAsync(string userUId, Card card);
        Task<bool> UpdateInboxCardAsync(string cardId, string userId, Card card);
    }
}
