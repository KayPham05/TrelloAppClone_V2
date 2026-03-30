
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface ICardMemberService
    {
        Task<List<CardMember>> GetAllUserMemberByCardUId(string cardUId);
        Task<bool> AddCardMember(string userUId, string requesterUId, string boardUId, string cardUId);
        Task<bool> RemoveCardMember(string userUId, string requesterUId, string boardUId, string cardUId);
    }
}
