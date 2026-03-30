using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class WorkspaceService : IWorkspaceService
    {
        private readonly TodoDbContext _context;
        public WorkspaceService(TodoDbContext context)
        {
            _context = context;
        }
        
        public async Task<bool> AddWorkspace(string creatorUserId, string name, string? description = null)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Validate user exists
                var user = await _context.Users.FindAsync(creatorUserId);
                if (user == null)
                    return false;

                // 2. Create Workspace
                var workspace = new Workspace
                {
                    WorkspaceUId = Guid.NewGuid().ToString(),
                    Name = name,
                    Description = description,
                    OwnerUId = creatorUserId,
                    Status = "Active",
                    CreatedAt = DateTime.UtcNow
                };

                await _context.Workspaces.AddAsync(workspace);
                await _context.SaveChangesAsync();

                // 3. Auto add creator as Owner in WorkspaceMember
                var ownerMember = new WorkspaceMemberDto
                {
                    WorkspaceMemberUId = Guid.NewGuid().ToString(),
                    WorkspaceUId = workspace.WorkspaceUId,
                    UserUId = creatorUserId,
                    Role = "Owner",
                    JoinedAt = DateTime.UtcNow
                };

                await _context.WorkspaceMembers.AddAsync(ownerMember);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                return true;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                Console.WriteLine($"Error creating workspace: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteWorkspace(string workspaceId, string requestUserId)
        {
            var workspace = await _context.Workspaces
                .Include(w => w.Members)
                .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);

            if (workspace == null)
                return false;

            // Only owner can delete
            if (workspace.OwnerUId != requestUserId)
                return false;

            workspace.Status = "Deleted"; // Soft delete
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateWorkspace(string workspaceId, string name, string? description, string requesterUId)
        {
            var workspace = await _context.Workspaces
                .Include(w => w.Members)
                .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);

            if (workspace == null)
                return false;

            // 🔹 Kiểm tra người thực hiện
            var requester = workspace.Members.FirstOrDefault(m => m.UserUId == requesterUId);
            if (requester == null || (requester.Role != "Owner" && requester.Role != "Admin"))
                return false;

            workspace.Name = name;
            workspace.Description = description;

            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<List<WorkspaceDTO>> GetAllWorkspaces(string userId)
        {
            return await _context.Workspaces
                .Where(w => (w.OwnerUId == userId || w.Members.Any(m => m.UserUId == userId)) && w.Status == "Active")
                .Select(w => new WorkspaceDTO
                {
                    WorkspaceUId = w.WorkspaceUId,
                    Name = w.Name,
                    Description = w.Description,
                    CreatedAt = w.CreatedAt,
                    Status = w.Status,
                    OwnerName = w.Owner.UserName,
                    Members = w.Members.Select(m => new MemberDTO
                    {
                        UserUId = m.UserUId,
                        UserName = m.User.UserName,
                        Role = m.Role
                    }).ToList()
                })
                .ToListAsync();
        }

        public async Task<Workspace?> GetWorkspaceByIdAsync(string workspaceId)
        {
            return await _context.Workspaces
               .Include(w => w.Owner)
               .Include(w => w.Members)
                   .ThenInclude(m => m.User)
               .Include(w => w.Boards)
                   .ThenInclude(b => b.Lists)
               .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);
        }


        public async Task<List<WorkspaceMembersDto>> GetWorkspaceMembers(string workspaceId)
        {
            return await _context.WorkspaceMembers
              .Where(m => m.WorkspaceUId == workspaceId)
              .Include(m => m.User)
              .OrderByDescending(m => m.Role == "Owner")
              .ThenBy(m => m.User.UserName)
              .Select(m => new WorkspaceMembersDto
              {
                  UserUId = m.UserUId,
                  Role = m.Role,
                  UserName = m.User != null ? m.User.UserName : "",
                  Email = m.User != null ? m.User.Email : ""
              })
              .ToListAsync();
        }

        public async Task<bool> InviteUserToWorkspace(string workspaceId, string userId, string requesterUId, string role)
        {
            try
            {
                bool exists = await _context.Workspaces
                    .AnyAsync(w => w.WorkspaceUId == workspaceId);
                if (!exists)
                    return false;

                var requester = await _context.WorkspaceMembers
                    .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == requesterUId);
                if (requester == null)
                    return false;

                if (requester.Role != "Owner" && requester.Role != "Admin")
                    return false;

                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.UserUId == userId);
                if (user == null)
                    return false;

                var existingMember = await _context.WorkspaceMembers
                    .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);
                if (existingMember != null)
                    return false;

                var newMember = new WorkspaceMemberDto
                {
                    WorkspaceMemberUId = Guid.NewGuid().ToString(),
                    WorkspaceUId = workspaceId,
                    UserUId = userId,
                    Role = role, 
                    JoinedAt = DateTime.UtcNow
                };

                await _context.WorkspaceMembers.AddAsync(newMember);
                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Error inviting user to workspace: {ex.Message}");
                return false;
            }
        }


        public async Task<bool> IsUserWorkspaceMember(string workspaceId, string userId)
        {
            return await _context.WorkspaceMembers
                .AnyAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);
        }

        public async Task<bool> RemoveMemberFromWorkspace(string workspaceId, string userId, string requesterUId)
        {
            var target = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);

            if (target == null)
                return false;

            var requester = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == requesterUId);

            if (requester == null)
                return false;

            if (requesterUId == userId)
                return false;

            if (requester.Role != "Owner" && requester.Role != "Admin")
                return false;

            if (target.Role == "Owner")
                return false;

            if (requester.Role == "Admin" && target.Role == "Admin")
                return false;

            _context.WorkspaceMembers.Remove(target);
            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<bool> UpdateMemberRole(string workspaceId, string userId, string newRole, string requesterUId)
        {
            var requester = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == requesterUId);

            var target = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == userId);

            if (requester == null || target == null)
                return false;

            // Không được tự đổi vai trò của chính mình
            if (requesterUId == userId)
                return false;

            // Nếu target là Owner mà requester không phải Owner => cấm
            if (target.Role == "Owner" && requester.Role != "Owner")
                return false;

            // Nếu requester là Admin
            if (requester.Role == "Admin")
            {
                // Admin không được đổi Owner/Admin
                if (target.Role == "Owner" || target.Role == "Admin")
                    return false;

                // Admin không thể cấp quyền Admin/Owner cho người khác
                if (newRole == "Admin" || newRole == "Owner")
                    return false;
            }

            // Nếu requester là Member hoặc Viewer => không có quyền đổi ai
            if (requester.Role == "Member" || requester.Role == "Viewer")
                return false;

            // Cập nhật role
            target.Role = newRole;
            await _context.SaveChangesAsync();
            return true;
        }



        public async Task<List<Board>> GetWorkspaceBoards(string workspaceId, string userId)
        {
            var isWorkspaceMember = await IsUserWorkspaceMember(workspaceId, userId);

            if (!isWorkspaceMember)
            {

                return await _context.Boards
                    .Where(b => b.WorkspaceUId == workspaceId &&
                               b.Members.Any(m => m.UserUId == userId))
                    .Include(b => b.Lists)
                    .ToListAsync();
            }

            return await _context.Boards
                .Where(b => b.WorkspaceUId == workspaceId &&
                           (b.Visibility == "Private" ||
                            b.Members.Any(m => m.UserUId == userId)))
                .Include(b => b.Lists)
                .OrderBy(b => b.BoardName)
                .ToListAsync();
        }
    }
}
