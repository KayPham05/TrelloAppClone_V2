using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class AuthorizationService : IAuthorizationService
    {
        private readonly TodoDbContext _context;

        public AuthorizationService(TodoDbContext context)
        {
            _context = context;
        }

        // ==================== WORKSPACE AUTHORIZATION ====================

        public async Task<bool> CanManageWorkspaceAsync(string workspaceId, string userId)
        {
            var member = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);

            if (member == null) return false;

            return member.Role == RoleConstants.WorkspaceOwner || member.Role == RoleConstants.WorkspaceAdmin;
        }

        public async Task<bool> CanCreateBoardInWorkspaceAsync(string workspaceId, string userId)
        {
            var member = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);

            if (member == null) return false;

            return member.Role == RoleConstants.WorkspaceOwner || 
                   member.Role == RoleConstants.WorkspaceAdmin || 
                   member.Role == RoleConstants.WorkspaceMember;
        }

        public async Task<bool> CanManageWorkspaceMembersAsync(string workspaceId, string userId)
        {
            var member = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);

            if (member == null) return false;

            return member.Role == RoleConstants.WorkspaceOwner || member.Role == RoleConstants.WorkspaceAdmin;
        }

        public async Task<bool> CanUpdateMemberRoleAsync(string workspaceId, string userId, string targetRole)
        {
            var member = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);

            if (member == null) return false;

            // Admin cannot assign roles higher than Member (cannot assign Admin/Owner)
            if (member.Role == RoleConstants.WorkspaceAdmin)
            {
                return targetRole != RoleConstants.WorkspaceAdmin && targetRole != RoleConstants.WorkspaceOwner;
            }

            // Only Owner can assign any role
            return member.Role == RoleConstants.WorkspaceOwner;
        }

        // ==================== BOARD AUTHORIZATION ====================

        public async Task<bool> CanManageBoardAsync(string boardId, string userId)
        {
            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardId && m.UserUId == userId);

            if (member == null)
            {
                // Logic for Workspace Inheritance: Workspace Admin/Owner can manage boards in their workspace
                var board = await _context.Boards.FindAsync(boardId);
                if (board != null && !string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    return await CanManageWorkspaceAsync(board.WorkspaceUId, userId);
                }
                return false;
            }

            return member.BoardRole == RoleConstants.BoardOwner || member.BoardRole == RoleConstants.BoardAdmin;
        }

        public async Task<bool> CanEditBoardAsync(string boardId, string userId)
        {
            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardId && m.UserUId == userId);

            if (member == null)
            {
                var board = await _context.Boards.FindAsync(boardId);
                if (board != null && !string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    return await CanManageWorkspaceAsync(board.WorkspaceUId, userId);
                }
                return false;
            }

            return member.BoardRole == RoleConstants.BoardOwner || member.BoardRole == RoleConstants.BoardAdmin;
        }

        public async Task<bool> CanDeleteBoardAsync(string boardId, string userId)
        {
            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardId && m.UserUId == userId);

            if (member == null)
            {
                // Workspace Owner can delete any board in the workspace
                var board = await _context.Boards.FindAsync(boardId);
                if (board != null && !string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    var wsMember = await _context.WorkspaceMembers
                        .FirstOrDefaultAsync(m => m.WorkspaceUId == board.WorkspaceUId && m.UserUId == userId);
                    return wsMember?.Role == RoleConstants.WorkspaceOwner;
                }
                return false;
            }

            return member.BoardRole == RoleConstants.BoardOwner;
        }

        public async Task<bool> CanManageBoardMembersAsync(string boardId, string userId)
        {
            return await CanManageBoardAsync(boardId, userId);
        }

        // ==================== LIST & CARD AUTHORIZATION ====================

        public async Task<bool> CanCreateCardAsync(string boardId, string userId)
        {
            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardId && m.UserUId == userId);

            if (member == null)
            {
                // Check if user is workspace member and board is public/open
                var board = await _context.Boards.FindAsync(boardId);
                if (board != null && !string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    return await CanCreateBoardInWorkspaceAsync(board.WorkspaceUId, userId);
                }
                return false;
            }

            return member.BoardRole == RoleConstants.BoardOwner || 
                   member.BoardRole == RoleConstants.BoardAdmin || 
                   member.BoardRole == RoleConstants.BoardEditor;
        }

        public async Task<bool> CanEditCardAsync(string cardId, string userId)
        {
            var card = await _context.Todos
                .Include(c => c.List)
                .FirstOrDefaultAsync(c => c.CardUId == cardId);

            if (card == null) return false;

            var boardId = card.List?.BoardUId;
            if (boardId == null) 
            {
                var isInboxOwner = await _context.UserInboxCards.AnyAsync(u => u.CardUId == cardId && u.UserUId == userId);
                return isInboxOwner;
            }

            return await CanCreateCardAsync(boardId, userId);
        }

        public async Task<bool> CanDeleteCardAsync(string cardId, string userId)
        {
            var card = await _context.Todos
                .Include(c => c.List)
                .FirstOrDefaultAsync(c => c.CardUId == cardId);

            if (card == null) return false;

            var boardId = card.List?.BoardUId;
            if (boardId == null) 
            {
                var isInboxOwner = await _context.UserInboxCards.AnyAsync(u => u.CardUId == cardId && u.UserUId == userId);
                return isInboxOwner;
            }

            return await CanManageBoardAsync(boardId, userId);
        }

        public async Task<bool> CanCommentOnCardAsync(string cardId, string userId)
        {
            var card = await _context.Todos
                .Include(c => c.List)
                .FirstOrDefaultAsync(c => c.CardUId == cardId);

            if (card == null) return false;

            var boardId = card.List?.BoardUId;
            if (boardId == null) 
            {
                var isInboxOwner = await _context.UserInboxCards.AnyAsync(u => u.CardUId == cardId && u.UserUId == userId);
                return isInboxOwner;
            }

            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardId && m.UserUId == userId);

            if (member == null)
            {
                // Workspace members can comment on workspace boards they have access to
                var board = await _context.Boards.FindAsync(boardId);
                if (board != null && !string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    return await _context.WorkspaceMembers
                        .AnyAsync(m => m.WorkspaceUId == board.WorkspaceUId && m.UserUId == userId);
                }
                return false;
            }

            return member.BoardRole != RoleConstants.BoardViewer;
        }

        public async Task<bool> CanCreateListAsync(string boardId, string userId)
        {
            return await CanCreateCardAsync(boardId, userId);
        }

        public async Task<bool> CanEditListAsync(string listId, string userId)
        {
            var list = await _context.Lists.FindAsync(listId);
            if (list == null) return false;

            return await CanCreateCardAsync(list.BoardUId, userId);
        }

        public async Task<bool> CanDeleteListAsync(string listId, string userId)
        {
            var list = await _context.Lists.FindAsync(listId);
            if (list == null) return false;

            return await CanManageBoardAsync(list.BoardUId, userId);
        }

        // ==================== GENERIC METHODS ====================

        public async Task<string?> GetUserRoleAsync(string resourceId, string userId, string resourceType)
        {
            if (resourceType == "Workspace")
            {
                var member = await _context.WorkspaceMembers
                    .FirstOrDefaultAsync(m => m.WorkspaceUId == resourceId && m.UserUId == userId);
                return member?.Role;
            }

            if (resourceType == "Board")
            {
                var member = await _context.BoardMembers
                    .FirstOrDefaultAsync(m => m.BoardUId == resourceId && m.UserUId == userId);
                return member?.BoardRole;
            }

            return null;
        }

        public async Task<bool> HasMinimumRoleAsync(string resourceId, string userUId, string resourceType, string minimumRole)
        {
            var role = await GetUserRoleAsync(resourceId, userUId, resourceType);
            if (role == null) return false;

            return CheckRolePriority(role, minimumRole, resourceType);
        }

        public async Task LogPermissionChangeAsync(string resourceId, string resourceType, string targetUserUId, string actionByUserUId, string actionType, string? oldRole, string? newRole)
        {
            var audit = new PermissionAudit
            {
                ResourceId = resourceId,
                ResourceType = resourceType,
                TargetUserUId = targetUserUId,
                ActionByUserUId = actionByUserUId,
                ActionType = actionType,
                OldRole = oldRole,
                NewRole = newRole,
                ActionAt = DateTime.UtcNow
            };

            _context.PermissionAudits.Add(audit);
            await _context.SaveChangesAsync();
        }

        private bool CheckRolePriority(string userRole, string minimumRole, string resourceType)
        {
            var rolePriority = new Dictionary<string, int>
            {
                { RoleConstants.WorkspaceViewer, 0 },
                { RoleConstants.BoardViewer, 0 },
                { RoleConstants.WorkspaceMember, 1 },
                { RoleConstants.BoardEditor, 1 },
                { RoleConstants.WorkspaceAdmin, 2 },
                { RoleConstants.BoardAdmin, 2 },
                { RoleConstants.WorkspaceOwner, 3 },
                { RoleConstants.BoardOwner, 3 }
            };

            if (!rolePriority.ContainsKey(userRole) || !rolePriority.ContainsKey(minimumRole))
                return false;

            return rolePriority[userRole] >= rolePriority[minimumRole];
        }
    }
}
