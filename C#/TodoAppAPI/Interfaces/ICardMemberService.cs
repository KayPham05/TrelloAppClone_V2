
using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface ICardMemberService
    {
        Task<List<MemberDTO>> GetAllUserMemberByCardUId(string cardUId);
        Task<bool> AddCardMember(string userUId, string requesterUId, string boardUId, string cardUId);
        Task<bool> RemoveCardMember(string userUId, string requesterUId, string boardUId, string cardUId);
        Task<bool> UpdateCardMemberRole(string cardUId, string userUId, string newRole, string requesterUId);
    }
}
