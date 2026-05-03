using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
namespace TodoAppAPI.Services
{
    public class BoardMemberService : IBoardMemberService
    {
        private readonly TodoDbContext _context;
        private readonly IAuthorizationService _authService;

        public BoardMemberService(TodoDbContext context, IAuthorizationService authService)
        {
            _context = context;
            _authService = authService;
        }

        public async Task<bool> AddBoardMemberAsync(string boardUId, string userUId, string requesterUId, string role)
        {
            try
            {
                // Kiểm tra requester có quyền mời không
                if (!await _authService.CanManageBoardMembersAsync(boardUId, requesterUId))
                    return false;

                // Kiểm tra người được mời có tồn tại không
                var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
                if (user == null)
                    return false;

                // Kiểm tra người này đã có trong board chưa
                bool exists = await _context.BoardMembers
                    .AnyAsync(bm => bm.BoardUId == boardUId && bm.UserUId == userUId);
                if (exists)
                    return false;

                // Thêm thành viên mới
                var newMember = new BoardMember
                {
                    BoardUId = boardUId,
                    UserUId = userUId,
                    BoardRole = role,
                    InvitedAt = DateTime.UtcNow
                };

                _context.BoardMembers.Add(newMember);
                await _context.SaveChangesAsync();

                await _authService.LogPermissionChangeAsync(boardUId, "Board", userUId, requesterUId, "AddMember", null, role);

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding board member: {ex.Message}");
                return false;
            }
        }

        // Cập nhật vai trò của thành viên
        public async Task<bool> UpdateBoardMemberRoleAsync(string boardUId, string userUId, string newRole, string requesterUId)
        {
            try
            {
                // Chỉ Owner hoặc Admin có quyền cập nhật
                if (!await _authService.CanManageBoardMembersAsync(boardUId, requesterUId))
                    return false;

                var target = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == userUId);
                if (target == null)
                    return false;

                // Không được đổi quyền chính mình
                if (target.UserUId == requesterUId)
                    return false;

                var oldRole = target.BoardRole;
                target.BoardRole = newRole;
                await _context.SaveChangesAsync();

                await _authService.LogPermissionChangeAsync(boardUId, "Board", userUId, requesterUId, "UpdateRole", oldRole, newRole);

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating board member role: {ex.Message}");
                return false;
            }
        }

        // Xóa thành viên khỏi board
        public async Task<bool> RemoveBoardMemberAsync(string boardUId, string userUId, string requesterUId)
        {
            try
            {
                // Chỉ Owner/Admin được xóa
                if (!await _authService.CanManageBoardMembersAsync(boardUId, requesterUId))
                    return false;

                var target = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == userUId);
                if (target == null)
                    return false;

                // Không được xóa chính mình hoặc xóa Owner
                if (target.UserUId == requesterUId || target.BoardRole == "Owner")
                    return false;

                var oldRole = target.BoardRole;
                _context.BoardMembers.Remove(target);
                await _context.SaveChangesAsync();

                await _authService.LogPermissionChangeAsync(boardUId, "Board", userUId, requesterUId, "RemoveMember", oldRole, null);

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error removing board member: {ex.Message}");
                return false;
            }
        }

        // Lấy danh sách thành viên
        public async Task<List<MemberDTO>> GetBoardMembersAsync(string boardUId)
        {
            var members = await _context.BoardMembers
                .Include(bm => bm.User)
                .Where(bm => bm.BoardUId == boardUId)
                .Select(bm => new MemberDTO
                {
                    UserUId   = bm.UserUId,
                    UserName  = bm.User.UserName,
                    Email     = bm.User.Email,
                    AvatarUrl = bm.User.AvatarUrl,
                    Role      = bm.BoardRole
                })
                .ToListAsync();

            return members;
        }

        // Lấy vai trò của user trong board
        public async Task<string?> GetUserRoleInBoardAsync(string boardUId, string userUId)
        {
            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardUId && m.UserUId == userUId);
            return member?.BoardRole;
        }

        // Kiểm tra quyền thao tác
        public async Task<bool> HasPermissionAsync(string boardUId, string userUId, string requiredRole)
        {
            return await _authService.HasMinimumRoleAsync(boardUId, userUId, "Board", requiredRole);
        }

        // Chuyển board sang workspace mới + kéo theo thành viên board
        public async Task<(bool Success, string Message)> TransferBoardWorkspaceAsync(
            string boardUId, string newWorkspaceUId, string requesterUId)
        {
            try
            {
                // 1. Chỉ Owner board mới được chuyển
                var requesterRole = await GetUserRoleInBoardAsync(boardUId, requesterUId);
                if (requesterRole != "Owner")
                    return (false, "Chỉ Owner mới có thể chuyển bảng sang workspace khác.");

                // 2. Kiểm tra workspace đích tồn tại
                var targetWorkspace = await _context.Workspaces
                    .FirstOrDefaultAsync(w => w.WorkspaceUId == newWorkspaceUId);
                if (targetWorkspace == null)
                    return (false, "Workspace đích không tồn tại.");

                // 3. Cập nhật WorkspaceUId của board
                var board = await _context.Boards.FirstOrDefaultAsync(b => b.BoardUId == boardUId);
                if (board == null)
                    return (false, "Board không tồn tại.");

                board.WorkspaceUId = newWorkspaceUId;

                // 4. Lấy danh sách thành viên board hiện tại
                var boardMembers = await _context.BoardMembers
                    .Where(bm => bm.BoardUId == boardUId)
                    .ToListAsync();

                // 5. Với mỗi thành viên board, thêm vào workspace đích nếu chưa có
                foreach (var bm in boardMembers)
                {
                    bool alreadyInWorkspace = await _context.WorkspaceMembers
                        .AnyAsync(wm => wm.WorkspaceUId == newWorkspaceUId && wm.UserUId == bm.UserUId);

                    if (!alreadyInWorkspace)
                    {
                        _context.WorkspaceMembers.Add(new WorkspaceMembers
                        {
                            WorkspaceUId = newWorkspaceUId,
                            UserUId = bm.UserUId,
                            Role = bm.BoardRole == "Owner" ? "Admin" : "Member",
                            JoinedAt = DateTime.UtcNow
                        });
                    }
                }

                await _context.SaveChangesAsync();

                await _authService.LogPermissionChangeAsync(
                    boardUId, "Board", requesterUId, requesterUId,
                    "TransferWorkspace", board.WorkspaceUId, newWorkspaceUId);

                return (true, "Đã chuyển board sang workspace mới thành công.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error transferring board workspace: {ex.Message}");
                return (false, "Đã xảy ra lỗi khi chuyển workspace.");
            }
        }
    }
}
