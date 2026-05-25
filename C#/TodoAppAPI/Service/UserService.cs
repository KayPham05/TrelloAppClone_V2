using System.Net.WebSockets;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using OtpNet;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class UserService : IUserService
    {
        private readonly TodoDbContext _context;
        private readonly EmailService _emailService;
        private readonly IJwtService _jwtService;
        private readonly ILogger<UserService> _logger;

        public UserService(TodoDbContext context, EmailService emailService, IJwtService jwtService, ILogger<UserService> logger)
        {
            _context = context;
            _emailService = emailService;
            _jwtService = jwtService;
            _logger = logger;
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            return await _context.Users.ToListAsync();
        }

        public async Task<User?> GetByIdAsync(string userUId)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
        }

        public async Task AddAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(User user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(string userUId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user != null)
            {
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<User?> GetUserByEmail(string email)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            
        }


        public async Task<string> ResendVerificationCodeAsync(string email)
        {
            if (string.IsNullOrEmpty(email))
                throw new ArgumentException("Email không hợp lệ.");

            //  Tìm user theo email
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null)
                throw new Exception("Không tìm thấy tài khoản.");

            if (user.IsEmailVerified)
                return "Tài khoản này đã được xác thực trước đó.";

            //  Sinh mã xác thực mới
            string code = new Random().Next(100000, 999999).ToString();

            //  Cập nhật mã hash và thời gian hết hạn
            user.VerificationTokenHash = BCrypt.Net.BCrypt.HashPassword(code);
            user.VerificationTokenExpiresAt = DateTime.UtcNow.AddMinutes(5);


            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            // Gửi mail
            await _emailService.SendVerificationEmailAsync(email, code);

            return " Mã xác thực mới đã được gửi tới email của bạn (có hiệu lực trong 10 phút).";
        }

        public async Task<bool> AddBioByUserUId(string userUId, string BIO)
        {
            try {
                if (userUId == null) return false;
                var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
                if (user == null) return false;
                user.Bio = BIO;
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                    Console.WriteLine(ex.Message);
                    return false;
            }
        }

        public Task<string?> GetBioByUserUId(string userUId)
        {
            try
            {
                return _context.Users.Where(u => u.UserUId == userUId)
                    .Select(u => u.Bio)
                    .FirstOrDefaultAsync();
           }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
                return null;
            }
        }

        public async Task<bool> AddUserUSerName(string userUId, string username)
        {
            try
            {
                if (userUId == null || username == null) return false;
                var user = _context.Users.FirstOrDefault(u => u.UserUId == userUId);
                if (user == null) return false;
                user.UserName = username;
                await _context.SaveChangesAsync();
                return true;
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }

        public Task<string?> GetUserUserName(string userUId)
        {
            try
            {
                return _context.Users.
                    AsNoTracking()
                    .Where(u=>userUId == u.UserUId)
                    .Select(u=>u.UserName)
                    .FirstOrDefaultAsync();
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
                return null;
            }
        }

        public async Task<bool> ToggleTwoFactorAsync(string userUId, bool enabled)
        {
            var user = await _context.Users.FindAsync(userUId);
            if (user == null) return false;
            user.IsTwoFactorEnabled = enabled;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task UpdateStatusAccount(string userUId, string status)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user != null)
            {
                user.StatusAccount = "Logout";
                await _context.SaveChangesAsync();
            }
        }

        public async Task<AuthResponse> GetVerificationStatusAndResendIfExpiredAsync(string email)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null) return new AuthResponse { Message = "Account not found!" };

            if (user.IsEmailVerified) return new AuthResponse { Message = "Email already verified!" };

            var now = DateTime.UtcNow;

            // Nếu chưa có thời gian hết hạn hoặc đã hết hạn
            if (user.VerificationTokenExpiresAt == null || user.VerificationTokenExpiresAt <= now)
            {
                await ResendVerificationCodeAsync(email);
                return new AuthResponse
                {
                    Message = "Mã xác thực đã hết hạn và đã được gửi lại tự động.",
                    Email = email,
                    requiresVerification = true,
                    ExpiresInSeconds = 300 // Thường là 5 phút trong ResendVerificationCodeAsync
                };
            }

            var remaining = (int)(user.VerificationTokenExpiresAt.Value - now).TotalSeconds;
            return new AuthResponse
            {
                Message = "Mã xác thực vẫn còn hiệu lực.",
                Email = email,
                requiresVerification = true,
                ExpiresInSeconds = remaining
            };
        }

        /// <summary>
        /// Đổi mật khẩu (Atomic Request): Verify old pass → Verify 2FA → Hash new pass → Revoke sessions → Issue new tokens → Email notification (fire-and-forget).
        /// </summary>
        public async Task<AuthResponse> ChangePasswordAsync(string userUId, string oldPassword, string newPassword, string? twoFactorCode)
        {
            // 1. Lấy user từ DB
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy tài khoản.");

            // 2. Verify mật khẩu cũ bằng Bcrypt
            if (!BCrypt.Net.BCrypt.Verify(oldPassword, user.PasswordHash))
                throw new UnauthorizedAccessException("Mật khẩu cũ không chính xác.");

            // 3. Verify 2FA (QUAN TRỌNG)
            if (user.IsTwoFactorEnabled)
            {
                // Null Check TRƯỚC khi gọi thư viện TOTP → tránh Server 500
                if (string.IsNullOrWhiteSpace(twoFactorCode))
                    throw new ArgumentException("Vui lòng nhập mã xác thực 2FA.");

                if (string.IsNullOrEmpty(user.TwoFactorSecret))
                    throw new InvalidOperationException("Tài khoản chưa thiết lập khóa bí mật 2FA.");

                // Verify TOTP bằng Otp.NET
                var secretBytes = Base32Encoding.ToBytes(user.TwoFactorSecret);
                var totp = new Totp(secretBytes, step: 30, totpSize: 6);
                var window = new VerificationWindow(previous: 1, future: 1);

                bool isValid = totp.VerifyTotp(twoFactorCode, out long timeStepMatched, window);
                if (!isValid)
                    throw new UnauthorizedAccessException("Mã 2FA không hợp lệ.");

                _logger.LogInformation($"[ChangePassword] 2FA verified for user: {userUId}, timeStep: {timeStepMatched}");
            }

            // 4. Hash mật khẩu mới và lưu vào DB
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
            _context.Users.Update(user);

            // 5. Revoke TOÀN BỘ Refresh Token cũ của user
            var existingSession = await _context.UserSessions
                .FirstOrDefaultAsync(s => s.UserUId == userUId);

            // 6. Sinh cặp Token mới
            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();

            if (existingSession != null)
            {
                // Cập nhật session hiện tại thay vì Add mới để tránh lỗi duplicate key/tracking
                existingSession.RefreshToken = refreshToken;
                existingSession.ExpiresAt = DateTime.UtcNow.AddDays(7);
                existingSession.IsRevoked = false;
                _context.UserSessions.Update(existingSession);
            }
            else
            {
                // Tạo session mới
                await _context.UserSessions.AddAsync(new UserSession
                {
                    UserUId = userUId,
                    RefreshToken = refreshToken,
                    ExpiresAt = DateTime.UtcNow.AddDays(7),
                    IsRevoked = false
                });
            }

            await _context.SaveChangesAsync();

            // 7. Email thông báo (Fire-and-forget – không block HTTP request)
            _ = Task.Run(async () =>
            {
                try
                {
                    await _emailService.SendChangePasswordNotificationEmailAsync(user.Email);
                    _logger.LogInformation($"[ChangePassword] Notification email sent to: {user.Email}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"[ChangePassword] Failed to send notification email: {ex.Message}");
                }
            });

            _logger.LogInformation($"[ChangePassword] Password changed successfully for user: {userUId}");

            return new AuthResponse
            {
                Message = "Đổi mật khẩu thành công!",
                UserUId = user.UserUId,
                Token = accessToken,
                RefreshToken = refreshToken,
                Email = user.Email,
                UserName = user.UserName,
                IsTwoFactorEnabled = user.IsTwoFactorEnabled
            };
        }
    }
}
