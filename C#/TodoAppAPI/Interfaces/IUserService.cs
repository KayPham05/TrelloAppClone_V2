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
        Task<AuthResponse> GetVerificationStatusAndResendIfExpiredAsync(string email);
        Task<AuthResponse> ChangePasswordAsync(string userUId, string oldPassword, string newPassword, string? twoFactorCode);
        Task<object> CheckChangeEmailAsync(string userUId, string newEmail, string currentPassword);
        Task<bool> SendChangeEmailOtpAsync(string userUId, string newEmail, string currentPassword, string? twoFactorCode);
        Task<bool> ConfirmChangeEmailAsync(string userUId, string newEmail, string otpCode);
        Task<bool> LockAccountAsync(string token);
        Task<List<UserInviteSuggestionDTO>> GetInviteSuggestionsAsync(
            string query,
            string scope,
            string requesterUId,
            string? workspaceId,
            string? boardId,
            int limit = 10);
    }
}
