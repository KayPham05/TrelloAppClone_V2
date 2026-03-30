using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IUserInboxCard
    {
        Task<List<CardDTO>> GetCardInbox(string userUId);
        Task<bool> AddCardInbox(string userUId, string cardUId);
    }
}
