using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

using TodoAppAPI.DTOs;

namespace TodoAppAPI.Service
{
    public class ListService : IListService
    {
        private readonly TodoDbContext _context;
        private readonly IAuthorizationService _authService;

        public ListService(TodoDbContext context, IAuthorizationService authService)
        {
            _context = context;
            _authService = authService;
        }
        public async Task<List?> AddListAsync(List list, string userUId)
        {
            try
            {
                if (!await _authService.CanCreateListAsync(list.BoardUId, userUId))
                    return null;

                list.ListUId = Guid.NewGuid().ToString();
                _context.Lists.Add(list);
                await _context.SaveChangesAsync();
                return list;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm list: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> DeleteListAsync(string listUId, string userUId)
        {
            try
            {
                if (!await _authService.CanDeleteListAsync(listUId, userUId))
                    return false;

                var list = await _context.Lists.FirstOrDefaultAsync(l => l.ListUId == listUId);
                if(list == null) return false;
                _context.Lists.Remove(list);
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                Console.WriteLine($"Lỗi khi xóa list: {ex.Message}");
                return false;
            }
        }

        public async Task<List<ListDTO>> GetAllListsByBoardUidAsync(string boardUId)
        {
            return await _context.Lists
                 .Where(l => l.BoardUId == boardUId && l.Status == "Active")
                 .OrderBy(l => l.Position)
                 .Select(l => new ListDTO {
                     ListUId = l.ListUId,
                     ListName = l.ListName,
                     Position = l.Position,
                     Status = l.Status,
                     CreatedAt = l.CreatedAt,
                     BoardUId = l.BoardUId
                 })
                 .ToListAsync();
        }

        public async Task<List> GetListByIdAsync(string listUId)
        {
            return await _context.Lists.FirstOrDefaultAsync(l => l.ListUId == listUId);
        }

        public async Task<bool> UpdateListAsync(List list, string userUId)
        {
            try
            {
                if (!await _authService.CanEditListAsync(list.ListUId, userUId))
                    return false;

                var existing = await _context.Lists.FirstOrDefaultAsync(l => l.ListUId == list.ListUId);
                if (existing == null) return false;

                existing.ListName = list.ListName;
                existing.Position = list.Position;
                existing.Status = list.Status;

                _context.Lists.Update(existing);
                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật list: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateStatus(List list, string userUId)
        {
            try
            {
                if (!await _authService.CanEditListAsync(list.ListUId, userUId))
                    return false;

                var listUpdate = await _context.Lists.FirstOrDefaultAsync(l => l.ListUId == list.ListUId);
                if (listUpdate == null) return false;
                listUpdate.Status = list.Status;
                _context.Lists.Update(listUpdate);
                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật trạng thái list: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateListPositionAsync(string boardUId, List<List> newOrder, string userUId)
        {
            try
            {
                // Check if user can edit board (to reorder lists)
                if (!await _authService.CanEditBoardAsync(boardUId, userUId))
                    return false;

                foreach (var item in newOrder)
                {
                    var list = await _context.Lists.FirstOrDefaultAsync(l => l.ListUId == item.ListUId);
                    if (list != null)
                    {
                        list.Position = item.Position;
                    }
                }
                await _context.SaveChangesAsync();
                return true;
            }
            catch { return false; }
        }
    }
}
