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

        public BoardMemberService(TodoDbContext context)
        {
            _context = context;
        }

        public async Task<bool> AddBoardMemberAsync(string boardUId, string userUId, string requesterUId, string role)
        {
            try
            {
                // Kiểm tra requester có trong board không
                var requester = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == requesterUId);
                if (requester == null)
                    return false;

                // Chỉ Owner hoặc Admin board mới có quyền mời
                if (requester.BoardRole != "Owner" && requester.BoardRole != "Admin")
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
                var requester = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == requesterUId);
                if (requester == null)
                    return false;

                // Chỉ Owner hoặc Admin có quyền cập nhật
                if (requester.BoardRole != "Owner" && requester.BoardRole != "Admin")
                    return false;

                var target = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == userUId);
                if (target == null)
                    return false;

                // Không được đổi quyền chính mình
                if (target.UserUId == requesterUId)
                    return false;

                target.BoardRole = newRole;
                await _context.SaveChangesAsync();
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
                var requester = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == requesterUId);
                if (requester == null)
                    return false;

                var target = await _context.BoardMembers
                    .FirstOrDefaultAsync(bm => bm.BoardUId == boardUId && bm.UserUId == userUId);
                if (target == null)
                    return false;

                // Chỉ Owner/Admin được xóa
                if (requester.BoardRole != "Owner" && requester.BoardRole != "Admin")
                    return false;

                // Không được xóa chính mình hoặc xóa Owner
                if (target.UserUId == requesterUId || target.BoardRole == "Owner")
                    return false;

                _context.BoardMembers.Remove(target);
                await _context.SaveChangesAsync();
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
                    UserUId = bm.UserUId,
                    UserName = bm.User.UserName,
                    Role = bm.BoardRole
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
            var priority = new Dictionary<string, int>
            {
                { "Viewer", 0 },
                { "Editor", 1 },
                { "Admin", 2 },
                { "Owner", 3 }
            };

            var member = await _context.BoardMembers
                .FirstOrDefaultAsync(m => m.BoardUId == boardUId && m.UserUId == userUId);
            if (member == null)
            {
                var board = await _context.Boards.FirstOrDefaultAsync(b => b.BoardUId == boardUId);
                if (board?.Visibility == "Public" && !string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    bool inWorkspace = await _context.WorkspaceMembers
                        .AnyAsync(w => w.WorkspaceUId == board.WorkspaceUId && w.UserUId == userUId);
                    if (inWorkspace) return true;
                }
                return false;
            }

            if (!priority.ContainsKey(member.BoardRole) || !priority.ContainsKey(requiredRole))
                return false;

            return priority[member.BoardRole] >= priority[requiredRole];
        }
    }
}
