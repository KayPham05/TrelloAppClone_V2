using TodoAppAPI.DTOs;
using TodoAppAPI.Models;

namespace TodoAppAPI.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponse> RegisterAsync(string userName, string email, string password);
        Task<AuthResponse> LoginAsync(string email, string password);
        Task<AuthResponse> GoogleLoginAsync(string email, string name);
        Task<AuthResponse> VerifyOtpAsync(string email, string otp);
        Task<string?> RefreshAccessTokenAsync(string refreshToken);
        Task LogoutAsync(string refreshToken);
        Task<UserSession?> GetUserSessionByUserId(string userUId);
        Task<bool> SendTwoFactorOtpAsync(string email);
        Task<VerifyTwoFactorResponse> VerifyTwoFactorSetupAsync(string email, string otp);
    }
}
