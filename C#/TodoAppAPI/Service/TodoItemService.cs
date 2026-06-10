using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

using TodoAppAPI.DTOs;

namespace TodoAppAPI.Service
{
    public class TodoItemService : ITodoItemService
    {
        private readonly TodoDbContext _dbContext;
        public TodoItemService(TodoDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public async Task<bool> AddTodoItem(string cardUId, string content)
        {
            try
            {
                TodoItem todoItem = new TodoItem
                {
                    TodoItemUId = Guid.NewGuid().ToString(),
                    CardUId = cardUId,
                    CreatedAt = DateTime.UtcNow,
                    Content = content.Trim(),
                    IsCompleted = false,
                };
                _dbContext.TodoItems.Add(todoItem);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex) {
                Console.WriteLine("khong the them todoItem", ex);
                return false;
            }

        }

        public async Task<bool> DeleteTodoItem(string todoItemUId)
        {
            try
            {
                var todoItem = await _dbContext.TodoItems.FindAsync(todoItemUId);
                if (todoItem == null) return false;

                _dbContext.TodoItems.Remove(todoItem);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Không thể xóa TodoItem: {ex.Message}");
                return false;
            }
        }


        public async Task<List<TodoItemDTO>> GetTodoItemByCardUId(string cardUId)
        {
            var items = await _dbContext.TodoItems
                .Where(t => t.CardUId == cardUId)
                .OrderByDescending(t => t.CreatedAt)
                .Select(t => new TodoItemDTO {
                    TodoItemUId = t.TodoItemUId,
                    Content = t.Content,
                    IsCompleted = t.IsCompleted,
                    CreatedAt = t.CreatedAt,
                    CardUId = t.CardUId
                })
                .ToListAsync();

            return items ?? new List<TodoItemDTO>();
        }


        public async Task<bool> UpdateStatusTodoItem(string todoItemUId, string status)
        {
            try
            {
                var todoItem = await _dbContext.TodoItems.FirstOrDefaultAsync(t => t.TodoItemUId == todoItemUId);
                if (todoItem == null) return false;

                todoItem.IsCompleted = string.Equals(status, "completed", StringComparison.OrdinalIgnoreCase);

                _dbContext.TodoItems.Update(todoItem);
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Không thể cập nhật TodoItem: {ex.Message}");
                return false;
            }
        }

        public async Task<TodoItemDTO?> GetTodoItemById(string todoItemUId)
        {
            var item = await _dbContext.TodoItems
                .Where(t => t.TodoItemUId == todoItemUId)
                .Select(t => new TodoItemDTO
                {
                    TodoItemUId = t.TodoItemUId,
                    Content = t.Content,
                    IsCompleted = t.IsCompleted,
                    CreatedAt = t.CreatedAt,
                    CardUId = t.CardUId
                })
                .FirstOrDefaultAsync();

            return item;
        }
    }
}
