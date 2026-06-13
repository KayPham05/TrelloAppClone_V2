using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class WorkspaceService : IWorkspaceService
    {
        private readonly TodoDbContext _context;
        private readonly IAuthorizationService _authService;
        private readonly INotificationService _notificationService;

        public WorkspaceService(
            TodoDbContext context,
            IAuthorizationService authService,
            INotificationService notificationService)
        {
            _context = context;
            _authService = authService;
            _notificationService = notificationService;
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
                var ownerMember = new WorkspaceMembers
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
            if (!await _authService.CanManageWorkspaceAsync(workspaceId, requesterUId))
                return false;

            var oldName = workspace.Name;
            workspace.Name = name;
            workspace.Description = description;

            await _context.SaveChangesAsync();

            if (!string.Equals(oldName, name, StringComparison.Ordinal))
            {
                var actorName = await GetUserDisplayNameAsync(requesterUId);
                var recipients = workspace.Members?
                    .Where(m => m.UserUId != requesterUId)
                    .Select(m => m.UserUId)
                    .Distinct()
                    .ToList() ?? new List<string>();

                foreach (var recipientId in recipients)
                {
                    await _notificationService.TryCreateInternalAsync(new NotificationDTO
                    {
                        RecipientId = recipientId,
                        ActorId = requesterUId,
                        Type = NotificationType.WorkspaceRenamed,
                        Title = "Tên không gian làm việc đã thay đổi",
                        Message = $"{actorName} đã đổi tên không gian làm việc {oldName} thành {name}.",
                        WorkspaceId = workspaceId,
                        Link = $"/workspace-menu/{workspaceId}"
                    }, "workspace rename");
                }
            }

            return true;
        }


        public async Task<List<WorkspaceDTO>> GetAllWorkspaces(string userId)
        {
            var starredBoardIds = await _context.UserStarredBoards
                .AsNoTracking()
                .Where(s => s.UserUId == userId)
                .Select(s => s.BoardUId)
                .ToHashSetAsync();

            var workspaces = await _context.Workspaces
                .AsNoTracking()
                .Include(w => w.Owner)
                .Include(w => w.Members!)
                    .ThenInclude(m => m.User)
                .Include(w => w.Boards!)
                    .ThenInclude(b => b.Members)
                .Where(w => (w.OwnerUId == userId || w.Members!.Any(m => m.UserUId == userId)) && w.Status == "Active")
                .ToListAsync();

            return workspaces.Select(w =>
                {
                    var workspaceRole = w.OwnerUId == userId
                        ? RoleConstants.WorkspaceOwner
                        : w.Members?.FirstOrDefault(m => m.UserUId == userId)?.Role;

                    var canManageWorkspace =
                        workspaceRole == RoleConstants.WorkspaceOwner ||
                        workspaceRole == RoleConstants.WorkspaceAdmin;

                    var visibleBoards = canManageWorkspace
                        ? w.Boards ?? new List<Board>()
                        : (w.Boards ?? new List<Board>())
                            .Where(b => b.Visibility != "Private" || (b.Members?.Any(m => m.UserUId == userId) ?? false))
                            .ToList();

                    return new WorkspaceDTO
                {
                    WorkspaceUId = w.WorkspaceUId,
                    Name = w.Name,
                    Description = w.Description,
                    CreatedAt = w.CreatedAt,
                    Status = w.Status,
                    OwnerName = w.Owner?.UserName ?? string.Empty,
                    OwnerUId = w.OwnerUId,
                    Type = "team", // Default to team for these workspaces
                    Members = w.Members!.Select(m => new MemberDTO
                    {
                        UserUId = m.UserUId,
                        UserName = m.User?.UserName ?? string.Empty,
                        Role = m.Role
                    }).ToList(),
                    Boards = visibleBoards.Select(b => new BoardDTO
                    {
                        BoardUId = b.BoardUId,
                        BoardName = b.BoardName,
                        Visibility = b.Visibility,
                        IsPersonal = b.IsPersonal,
                        WorkspaceUId = b.WorkspaceUId,
                        BackgroundUrl = b.BackgroundUrl,
                        Status = b.Status,
                        CreatedAt = b.CreatedAt,
                        UserUId = b.UserUId,
                        IsStarred = starredBoardIds.Contains(b.BoardUId)
                    }).ToList()
                };
                })
                .ToList();
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
                  UserUId   = m.UserUId,
                  Role      = m.Role,
                  UserName  = m.User != null ? m.User.UserName : "",
                  Email     = m.User != null ? m.User.Email : "",
                  AvatarUrl = m.User != null ? m.User.AvatarUrl : null
              })
              .ToListAsync();
        }

        public async Task<bool> InviteUserToWorkspace(string workspaceId, string userId, string requesterUId, string role)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userId))
                    return false;

                bool exists = await _context.Workspaces
                    .AnyAsync(w => w.WorkspaceUId == workspaceId);
                if (!exists)
                    return false;

                if (!await _authService.CanManageWorkspaceMembersAsync(workspaceId, requesterUId))
                    return false;

                var userIdentifier = userId.Trim();
                var normalizedEmail = userIdentifier.ToLowerInvariant();
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.UserUId == userIdentifier || (u.Email != null && u.Email.ToLower() == normalizedEmail));
                if (user == null)
                    return false;

                var targetUserUId = user.UserUId;
                var existingMember = await _context.WorkspaceMembers
                    .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceId && m.UserUId == targetUserUId);
                if (existingMember != null)
                    return false;

                var newMember = new WorkspaceMembers
                {
                    WorkspaceMemberUId = Guid.NewGuid().ToString(),
                    WorkspaceUId = workspaceId,
                    UserUId = targetUserUId,
                    Role = role, 
                    JoinedAt = DateTime.UtcNow
                };

                _context.WorkspaceMembers.Add(newMember);
                await _context.SaveChangesAsync();

                await _authService.LogPermissionChangeAsync(workspaceId, "Workspace", targetUserUId, requesterUId, "InviteMember", null, role);

                if (targetUserUId != requesterUId)
                {
                    var workspace = await _context.Workspaces.AsNoTracking().FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);
                    var actorName = await GetUserDisplayNameAsync(requesterUId);
                    var workspaceName = workspace?.Name ?? workspaceId;
                    await _notificationService.TryCreateInternalAsync(new NotificationDTO
                    {
                        RecipientId = targetUserUId,
                        ActorId = requesterUId,
                        Type = NotificationType.WorkspaceMemberAdded,
                        Title = "Bạn đã được thêm vào không gian làm việc",
                        Message = $"Bạn đã được {actorName} thêm vào {workspaceName}.",
                        WorkspaceId = workspaceId,
                        Link = $"/workspace-menu/{workspaceId}"
                    }, "workspace member invite");
                }

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

            if (!await _authService.CanManageWorkspaceMembersAsync(workspaceId, requesterUId))
                return false;

            if (target.Role == RoleConstants.WorkspaceOwner)
                return false;

            // Admin cannot remove other Admins (handled by logic within auth if needed or here)
            // For now keep the explicit check or move to auth service
            var requesterRole = await _authService.GetUserRoleAsync(workspaceId, requesterUId, "Workspace");
            if (requesterRole == RoleConstants.WorkspaceAdmin && target.Role == RoleConstants.WorkspaceAdmin)
                return false;

            _context.WorkspaceMembers.Remove(target);
            await _context.SaveChangesAsync();

            await _authService.LogPermissionChangeAsync(workspaceId, "Workspace", userId, requesterUId, "RemoveMember", target.Role, null);

            if (userId != requesterUId)
            {
                var workspace = await _context.Workspaces.AsNoTracking().FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);
                var actorName = await GetUserDisplayNameAsync(requesterUId);
                var workspaceName = workspace?.Name ?? workspaceId;
                await _notificationService.TryCreateInternalAsync(new NotificationDTO
                {
                    RecipientId = userId,
                    ActorId = requesterUId,
                    Type = NotificationType.WorkspaceMemberRemoved,
                    Title = "Bạn đã bị xóa khỏi không gian làm việc",
                    Message = $"Bạn đã bị {actorName} xóa khỏi {workspaceName}.",
                    WorkspaceId = workspaceId,
                    Link = $"/workspace-menu/{workspaceId}"
                }, "workspace member remove");
            }

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

            if (!await _authService.CanUpdateMemberRoleAsync(workspaceId, requesterUId, newRole))
                return false;
            
            // Cập nhật role
            var oldRole = target.Role;
            target.Role = newRole;
            await _context.SaveChangesAsync();

            await _authService.LogPermissionChangeAsync(workspaceId, "Workspace", userId, requesterUId, "UpdateRole", oldRole, newRole);

            if (userId != requesterUId)
            {
                var workspace = await _context.Workspaces.AsNoTracking().FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);
                var actorName = await GetUserDisplayNameAsync(requesterUId);
                await _notificationService.TryCreateInternalAsync(new NotificationDTO
                {
                    RecipientId = userId,
                    ActorId = requesterUId,
                    Type = NotificationType.WorkspaceRoleChanged,
                    Title = "Vai trò trong không gian làm việc đã thay đổi",
                    Message = $"{actorName} đã thay đổi vai trò của bạn từ {ToVietnameseRoleLabel(oldRole)} -> {ToVietnameseRoleLabel(newRole)}",
                    WorkspaceId = workspaceId,
                    Link = $"/workspace-menu/{workspaceId}"
                }, "workspace member role update");
            }
            
            return true;
        }



        public async Task<List<Board>> GetWorkspaceBoards(string workspaceId, string userId)
        {
            var workspace = await _context.Workspaces
                .AsNoTracking()
                .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId && w.Status != "Deleted");

            if (workspace == null)
                return new List<Board>();

            var workspaceRole = await _context.WorkspaceMembers
                .AsNoTracking()
                .Where(m => m.WorkspaceUId == workspaceId && m.UserUId == userId)
                .Select(m => m.Role)
                .FirstOrDefaultAsync();

            var canManageWorkspace =
                workspace.OwnerUId == userId ||
                workspaceRole == RoleConstants.WorkspaceOwner ||
                workspaceRole == RoleConstants.WorkspaceAdmin;

            if (canManageWorkspace)
            {
                return await _context.Boards
                    .Where(b => b.WorkspaceUId == workspaceId)
                    .Include(b => b.Lists)
                    .OrderBy(b => b.BoardName)
                    .ToListAsync();
            }

            if (workspaceRole == null)
                return new List<Board>();

            return await _context.Boards
                .Where(b => b.WorkspaceUId == workspaceId &&
                           (b.Visibility != "Private" || b.Members.Any(m => m.UserUId == userId)))
                .Include(b => b.Lists)
                .OrderBy(b => b.BoardName)
                .ToListAsync();
        }

        private async Task<string> GetUserDisplayNameAsync(string userUId)
        {
            var name = await _context.Users
                .AsNoTracking()
                .Where(u => u.UserUId == userUId)
                .Select(u => u.UserName)
                .FirstOrDefaultAsync();

            return string.IsNullOrWhiteSpace(name) ? userUId : name;
        }

        private static string ToVietnameseRoleLabel(string? role)
        {
            return role switch
            {
                "Owner" => "Chủ sở hữu",
                "Admin" => "Quản trị viên",
                "Member" => "Thành viên",
                "Viewer" => "Người xem",
                "Editor" => "Biên tập viên",
                "Assignee" => "Người thực hiện",
                "Observer" => "Người theo dõi",
                _ => string.IsNullOrWhiteSpace(role) ? "Không xác định" : role
            };
        }
    }
}
