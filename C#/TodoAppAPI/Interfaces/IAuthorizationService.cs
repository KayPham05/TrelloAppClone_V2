using System.Threading.Tasks;

namespace TodoAppAPI.Interfaces
{
    public interface IAuthorizationService
    {
        // ==================== WORKSPACE AUTHORIZATION ====================
        
        Task<bool> CanManageWorkspaceAsync(string workspaceId, string userId);
        Task<bool> CanCreateBoardInWorkspaceAsync(string workspaceId, string userId);
        Task<bool> CanManageWorkspaceMembersAsync(string workspaceId, string userId);
        Task<bool> CanUpdateMemberRoleAsync(string workspaceId, string userId, string targetRole);

        // ==================== BOARD AUTHORIZATION ====================
        
        Task<bool> CanManageBoardAsync(string boardId, string userId);
        Task<bool> CanViewBoardAsync(string boardId, string userId);
        Task<bool> CanEditBoardAsync(string boardId, string userId);
        Task<bool> CanDeleteBoardAsync(string boardId, string userId);
        Task<bool> CanManageBoardMembersAsync(string boardId, string userId);
        Task<bool> CanViewWorkspaceAnalysisAsync(string workspaceId, string userId);
        Task<bool> CanViewBoardAnalysisAsync(string boardId, string userId);
        Task<bool> CanViewCardAnalysisAsync(string cardId, string userId);

        // ==================== LIST & CARD AUTHORIZATION ====================
        
        Task<bool> CanCreateCardAsync(string boardId, string userId);
        Task<bool> CanEditCardAsync(string cardId, string userId);
        Task<bool> CanDeleteCardAsync(string cardId, string userId);
        Task<bool> CanCommentOnCardAsync(string cardId, string userId);

        Task<bool> CanCreateListAsync(string boardId, string userId);
        Task<bool> CanEditListAsync(string listId, string userId);
        Task<bool> CanDeleteListAsync(string listId, string userId);

        // ==================== GENERIC METHODS ====================
        
        Task<string?> GetUserRoleAsync(string resourceId, string userId, string resourceType);
        Task<bool> HasMinimumRoleAsync(string resourceId, string userUId, string resourceType, string minimumRole);

        // Audit Logging
        Task LogPermissionChangeAsync(string resourceId, string resourceType, string targetUserUId, string actionByUserUId, string actionType, string? oldRole, string? newRole);
    }
}
