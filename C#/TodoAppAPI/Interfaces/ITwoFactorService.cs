using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface ITwoFactorService
    {
        Task<Setup2FAResponse> Setup2FAAsync(string userUId);
        Task<Enable2FAResponse> Enable2FAAsync(string userUId, string code);
    }
}
