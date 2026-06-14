using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.DTOs;

namespace TodoAppAPI.Service
{
    public class UserBoardRecentService : IUserRecentBoardService
    {
        private readonly TodoDbContext _context;
        public UserBoardRecentService(TodoDbContext context)
        {
            _context = context;
        }
        public async Task<List<BoardDTO>> GetRecentBoardByUserUId(string userUId)
        {
            return await _context.UserRecentBoards
                .Where(x => x.UserUId == userUId)
                .OrderByDescending(x => x.LastVisitedAt)
                .Include(x => x.Board)
                .Take(20)
                .Select(x => new TodoAppAPI.DTOs.BoardDTO
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
                    IsStarred = _context.UserStarredBoards.Any(s =>
                        s.UserUId == userUId && s.BoardUId == x.BoardUId)
                })
                .ToListAsync();
            
        }

        public async Task<bool> SaveRecentBoard(string userUId, string boardUId)
        {
            try
            {
                var check = await _context.UserRecentBoards.FirstOrDefaultAsync(x => x.UserUId == userUId && x.BoardUId == boardUId);
                if (check != null)
                {
                    check.LastVisitedAt = DateTime.UtcNow;
                    _context.UserRecentBoards.Update(check);
                }
                else
                {
                    UserRecentBoard userRecent = new UserRecentBoard();
                    userRecent.UserRecentBoardUId = Guid.NewGuid().ToString();
                    userRecent.UserUId = userUId;
                    userRecent.BoardUId = boardUId;
                    userRecent.LastVisitedAt = DateTime.UtcNow;

                    await _context.UserRecentBoards.AddAsync(userRecent);
                    await _context.SaveChangesAsync();
                }

                var all = await _context.UserRecentBoards
                    .Where(x => x.UserUId == userUId)
                    .OrderByDescending(x => x.LastVisitedAt)
                    .ToListAsync();
                if (all.Count > 20)
                {
                    var toRemove = all.Skip(20).ToList();
                    _context.UserRecentBoards.RemoveRange(toRemove);
                    await _context.SaveChangesAsync();
                }

                return true;

            }
            catch (Exception ex) { 
                Console.WriteLine("Khong them duoc",ex.ToString());
                return false;
            }
        }
    }
}
