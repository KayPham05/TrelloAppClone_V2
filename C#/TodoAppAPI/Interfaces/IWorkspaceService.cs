using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IWorkspaceService
    {
        Task<bool> AddWorkspace(string creatorUserId, string name, string? description = null);
        Task<bool> UpdateWorkspace(string workspaceId, string name, string? description, string requesterUId);
        Task<bool> DeleteWorkspace(string workspaceId, string requestUserId);
        Task<List<WorkspaceDTO>> GetAllWorkspaces(string userUid);
        Task<Workspace?> GetWorkspaceByIdAsync(string workspaceId);

        Task<bool> InviteUserToWorkspace(string workspaceId, string userUId, string requesterUId, string  role);
        Task<bool> RemoveMemberFromWorkspace(string workspaceId, string userId, string requesterUId);
        Task<bool> UpdateMemberRole(string workspaceId, string userId, string newRole, string requesterUId);
        Task<List<WorkspaceMembersDto>> GetWorkspaceMembers(string workspaceId);
        Task<bool> IsUserWorkspaceMember(string workspaceId, string userId);

        Task<List<Board>> GetWorkspaceBoards(string workspaceId, string userId);
    }

}
