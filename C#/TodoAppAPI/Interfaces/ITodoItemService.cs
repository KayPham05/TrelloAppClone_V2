using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface ITodoItemService
    {
        Task<bool> AddTodoItem(string cardUId, string content);
        Task<bool> DeleteTodoItem(string todoItemUId);
        Task<bool> UpdateStatusTodoItem(string todoItemUId, string status);
        Task<List<TodoItemDTO>> GetTodoItemByCardUId(string cardUId);
        Task<TodoItemDTO?> GetTodoItemById(string todoItemUId);
    }
}
