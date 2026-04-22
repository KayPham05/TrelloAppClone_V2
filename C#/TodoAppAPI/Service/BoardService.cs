using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

using TodoAppAPI.DTOs;

namespace TodoAppAPI.Service
{
    public class BoardService : IBoardService
    {
        private readonly TodoDbContext _context;
        public BoardService(TodoDbContext context)
        {
            _context = context;
        }

        public async Task<Board?> AddBoardAsync(Board board)
        {
            try
            {
                // 1Kiểm tra quyền (nếu là workspace board)
                if (!string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    if (!await HasPermissionToCreateBoardAsync(board.UserUId, board.WorkspaceUId))
                    {
                        Console.WriteLine($"User {board.UserUId} không có quyền tạo board");
                        return null;
                    }
                }

                // Tạo board
                board.BoardUId = Guid.NewGuid().ToString();
                board.CreatedAt = DateTime.UtcNow;

                var membersList = board.Members?.ToList();
                board.Members = null; // Tránh EF tracking conflict

                _context.Boards.Add(board);

                //  Thêm members
                var membersToAdd = await BuildBoardMembersAsync(board, membersList);
                _context.BoardMembers.AddRange(membersToAdd);

                //  Lưu
                await _context.SaveChangesAsync();

                Console.WriteLine($" Board created: {board.BoardName} with {membersToAdd.Count} members");
                return board;
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Error: {ex.Message}");
                return null;
            }
        }



        private async Task<bool> HasPermissionToCreateBoardAsync(string userUId, string workspaceUId)
        {
            // Kiểm tra user đã là member chưa
            var member = await _context.WorkspaceMembers
                .FirstOrDefaultAsync(m => m.WorkspaceUId == workspaceUId && m.UserUId == userUId);

            if (member != null)
                return member.Role == "Owner" || member.Role == "Admin";

            // Fallback: Kiểm tra có phải workspace owner không
            var workspace = await _context.Workspaces
                .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceUId);

            if (workspace?.OwnerUId == userUId)
            {
                // Tự động thêm owner vào workspace members
                await AddOwnerToWorkspaceMembersAsync(workspaceUId, userUId);
                return true;
            }

            return false;
        }

        private async Task AddOwnerToWorkspaceMembersAsync(string workspaceUId, string userUId)
        {
            var newMember = new WorkspaceMemberDto
            {
                WorkspaceMemberUId = Guid.NewGuid().ToString(),
                WorkspaceUId = workspaceUId,
                UserUId = userUId,
                Role = "Owner",
                JoinedAt = DateTime.UtcNow
            };
            _context.WorkspaceMembers.Add(newMember);
            await _context.SaveChangesAsync();
            Console.WriteLine("✅ Auto-added workspace owner");
        }

        private async Task<List<BoardMember>> BuildBoardMembersAsync(Board board, List<BoardMember>? selectedMembers)
        {
            var members = new List<BoardMember>();

            // Luôn thêm creator làm Owner
            members.Add(CreateBoardMember(board.BoardUId, board.UserUId, "Owner"));

            // Board cá nhân → chỉ có owner
            if (string.IsNullOrEmpty(board.WorkspaceUId))
                return members;

            // Workspace board
            if (board.Visibility == "Private")
            {
                // Private: Thêm members được chọn
                members.AddRange(await GetSelectedMembersAsync(board, selectedMembers));
            }
            else
            {
                // Public: Thêm tất cả workspace members
                members.AddRange(await GetAllWorkspaceMembersAsync(board));
            }

            return members;
        }

        private async Task<List<BoardMember>> GetSelectedMembersAsync(Board board, List<BoardMember>? selectedMembers)
        {
            if (selectedMembers == null || !selectedMembers.Any())
                return new List<BoardMember>();

            var members = new List<BoardMember>();
            var validUserIds = await _context.Users
                .Where(u => selectedMembers.Select(m => m.UserUId).Contains(u.UserUId))
                .Select(u => u.UserUId)
                .ToListAsync();

            foreach (var m in selectedMembers)
            {
                if (m.UserUId == board.UserUId) continue; // Bỏ qua owner
                if (!validUserIds.Contains(m.UserUId)) continue; // Bỏ qua user không tồn tại

                var role = string.IsNullOrEmpty(m.BoardRole) ? "Viewer" : m.BoardRole;
                members.Add(CreateBoardMember(board.BoardUId, m.UserUId, role));
            }

            Console.WriteLine($" Added {members.Count} selected members");
            return members;
        }

        private async Task<List<BoardMember>> GetAllWorkspaceMembersAsync(Board board)
        {
            var workspaceMembers = await _context.WorkspaceMembers
                .Where(m => m.WorkspaceUId == board.WorkspaceUId && m.UserUId != board.UserUId)
                .Select(m => m.UserUId)
                .ToListAsync();

            var members = workspaceMembers
                .Select(userId => CreateBoardMember(board.BoardUId, userId, "Viewer"))
                .ToList();

            Console.WriteLine($"🌐 Added {members.Count} workspace members");
            return members;
        }

        private BoardMember CreateBoardMember(string boardUId, string userUId, string role)
        {
            return new BoardMember
            {
                BoardMemberUId = Guid.NewGuid().ToString(),
                BoardUId = boardUId,
                UserUId = userUId,
                BoardRole = role,
                InvitedAt = DateTime.UtcNow
            };
        }

        public async Task<bool> DeleteBoardAsync(string boardUId)
        {
            try
            {
                var board = await _context.Boards.FirstOrDefaultAsync(b => b.BoardUId == boardUId);
                if (board == null) return false;

                _context.Boards.Remove(board);
                await _context.SaveChangesAsync();
                return true;
            }catch(Exception ex)
            {
                Console.WriteLine($"Lỗi khi xóa board: {ex.Message}");
                return false;
            }
        }

        public async Task<List<BoardDTO>> GetAllBoardsByUserAsync(string userUId)
        {
            return await _context.Boards
            .Where(b => b.UserUId == userUId && b.IsPersonal == true)
            .OrderByDescending(c => c.CreatedAt)
            .Select(b => new BoardDTO {
                BoardUId = b.BoardUId,
                BoardName = b.BoardName,
                CreatedAt = b.CreatedAt,
                IsPersonal = b.IsPersonal,
                Visibility = b.Visibility,
                Status = b.Status,
                UserUId = b.UserUId,
                WorkspaceUId = b.WorkspaceUId,
                BackgroundUrl = b.BackgroundUrl
            })
            .ToListAsync();
        }

        public async Task<BoardDTO?> GetBoardByIdAsync(string boardUId)
        {
            return await _context.Boards
                .Where(b => b.BoardUId == boardUId)
                .Select(b => new BoardDTO {
                    BoardUId = b.BoardUId,
                    BoardName = b.BoardName,
                    CreatedAt = b.CreatedAt,
                    IsPersonal = b.IsPersonal,
                    Visibility = b.Visibility,
                    Status = b.Status,
                    UserUId = b.UserUId,
                    WorkspaceUId = b.WorkspaceUId,
                    BackgroundUrl = b.BackgroundUrl
                })
                .FirstOrDefaultAsync();
        }

        public Task<BoardDTO?> GetBoardByNameAsync(string boardName)
        {
            throw new NotImplementedException();
        }

        public async Task<bool> UpdateBoardAsync(Board board)
        {
            try
            {
                var boardUpdate = _context.Boards.FirstOrDefault(b => b.BoardUId == board.BoardUId);
                if (boardUpdate == null) return false;
                boardUpdate.BoardName = board.BoardName;
                boardUpdate.Visibility = string.IsNullOrEmpty(board.Visibility) 
                    ? boardUpdate.Visibility
                    : board.Visibility;
                boardUpdate.BackgroundUrl = board.BackgroundUrl;
                _context.Boards.Update(boardUpdate);
                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật board: {ex.Message}");
                return false;
            }
        }
    }
}
