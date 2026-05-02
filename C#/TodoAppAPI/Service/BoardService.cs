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
        private readonly IAuthorizationService _authService;

        public BoardService(TodoDbContext context, IAuthorizationService authService)
        {
            _context = context;
            _authService = authService;
        }

        public async Task<Board?> AddBoardAsync(Board board)
        {
            try
            {
                // Kiểm tra quyền (nếu là workspace board)
                if (!string.IsNullOrEmpty(board.WorkspaceUId))
                {
                    if (!await _authService.CanCreateBoardInWorkspaceAsync(board.WorkspaceUId, board.UserUId))
                    {
                        Console.WriteLine($"User {board.UserUId} không có quyền tạo board trong workspace {board.WorkspaceUId}");
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

        public async Task<bool> DeleteBoardAsync(string boardUId, string userUId)
        {
            try
            {
                if (!await _authService.CanDeleteBoardAsync(boardUId, userUId))
                {
                    return false;
                }
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

        public async Task<bool> UpdateBoardAsync(Board board, string userUId)
        {
            try
            {
                if (!await _authService.CanEditBoardAsync(board.BoardUId, userUId))
                {
                    return false;
                }
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
