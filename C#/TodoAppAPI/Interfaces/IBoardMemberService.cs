using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface IBoardMemberService
    {
        Task<bool> AddBoardMemberAsync(string boardUId, string userUId, string requesterUId, string role);
        Task<bool> UpdateBoardMemberRoleAsync(string boardUId, string userUId, string newRole, string requesterUId);
        Task<bool> RemoveBoardMemberAsync(string boardUId, string userUId, string requesterUId);
        Task<List<MemberDTO>> GetBoardMembersAsync(string boardUId);
        Task<string?> GetUserRoleInBoardAsync(string boardUId, string userUId);

        Task<bool> HasPermissionAsync(string boardUId, string userUId, string requiredRole);
    }
}
