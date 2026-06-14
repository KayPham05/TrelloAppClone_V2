using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Constants;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class UserStarredBoardService : IUserStarredBoardService
    {
        private readonly TodoDbContext _context;

        public UserStarredBoardService(TodoDbContext context)
        {
            _context = context;
        }

        public async Task<List<BoardDTO>> GetStarredBoardByUserUId(string userUId)
        {
            return await _context.UserStarredBoards
                .Where(x => x.UserUId == userUId)
                .OrderByDescending(x => x.StarredAt)
                .Include(x => x.Board)
                .Select(x => new BoardDTO
                {
                    BoardUId = x.Board!.BoardUId,
                    BoardName = x.Board.BoardName,
                    CreatedAt = x.Board.CreatedAt,
                    IsPersonal = x.Board.IsPersonal,
                    Visibility = x.Board.Visibility,
                    Status = x.Board.Status,
                    UserUId = x.Board.UserUId,
                    WorkspaceUId = x.Board.WorkspaceUId,
                    BackgroundUrl = x.Board.BackgroundUrl,
                    IsStarred = true
                })
                .ToListAsync();
        }

        public async Task<bool> SetStarredBoard(string userUId, string boardUId, bool isStarred)
        {
            var existing = await _context.UserStarredBoards
                .FirstOrDefaultAsync(x => x.UserUId == userUId && x.BoardUId == boardUId);

            if (!isStarred)
            {
                if (existing == null) return true;
                _context.UserStarredBoards.Remove(existing);
                await _context.SaveChangesAsync();
                return true;
            }

            if (!await CanUserAccessBoard(userUId, boardUId)) return false;

            if (existing != null)
            {
                existing.StarredAt = DateTime.UtcNow;
                _context.UserStarredBoards.Update(existing);
            }
            else
            {
                await _context.UserStarredBoards.AddAsync(new UserStarredBoard
                {
                    UserStarredBoardUId = Guid.NewGuid().ToString(),
                    UserUId = userUId,
                    BoardUId = boardUId,
                    StarredAt = DateTime.UtcNow
                });
            }

            await _context.SaveChangesAsync();
            return true;
        }

        private async Task<bool> CanUserAccessBoard(string userUId, string boardUId)
        {
            var board = await _context.Boards
                .AsNoTracking()
                .FirstOrDefaultAsync(b => b.BoardUId == boardUId && b.Status != "Deleted");

            if (board == null) return false;
            if (board.UserUId == userUId) return true;

            var boardMember = await _context.BoardMembers
                .AsNoTracking()
                .AnyAsync(m => m.BoardUId == boardUId && m.UserUId == userUId);
            if (boardMember) return true;

            if (string.IsNullOrEmpty(board.WorkspaceUId)) return false;

            var workspaceMember = await _context.WorkspaceMembers
                .AsNoTracking()
                .FirstOrDefaultAsync(m => m.WorkspaceUId == board.WorkspaceUId && m.UserUId == userUId);

            if (workspaceMember == null) return false;

            if (workspaceMember.Role == RoleConstants.WorkspaceOwner ||
                workspaceMember.Role == RoleConstants.WorkspaceAdmin)
            {
                return true;
            }

            return board.Visibility == "Public";
        }
    }
}
