using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IUserService
    {

        Task<IEnumerable<User>> GetAllAsync();
        Task<User?> GetByIdAsync(string userUId);
        Task AddAsync(User user);
        Task UpdateAsync(User user);
        Task DeleteAsync(string userUId);
        Task UpdateStatusAccount(string userUId, string status);
        Task <User?> GetUserByEmail(string email);
        Task<string> ResendVerificationCodeAsync(string email);

        Task<bool> AddBioByUserUId(string userUId, string BIO);

        Task<string?> GetBioByUserUId(string userUId);

        Task<bool> AddUserUSerName(String userUId, string username);

        Task<string?> GetUserUserName(string userUId);

        Task<bool> ToggleTwoFactorAsync(string userUId, bool enabled);
    }
}
