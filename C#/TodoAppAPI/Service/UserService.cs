using System.Net.WebSockets;
using System.Text;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using OtpNet;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Hubs;
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
        private readonly IHubContext<NotificationHub> _notificationHubContext;
        private readonly IMemoryCache _memoryCache;

        public UserService(TodoDbContext context, EmailService emailService, IJwtService jwtService, ILogger<UserService> logger, IMemoryCache memoryCache, IHubContext<NotificationHub> notificationHubContext)
        {
            _context = context;
            _emailService = emailService;
            _jwtService = jwtService;
            _logger = logger;
            _memoryCache = memoryCache;
            _notificationHubContext = notificationHubContext;
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

        public async Task<List<UserInviteSuggestionDTO>> GetInviteSuggestionsAsync(
            string query,
            string scope,
            string requesterUId,
            string? workspaceId,
            string? boardId,
            int limit = 10)
        {
            var normalizedQuery = (query ?? string.Empty).Trim().ToLowerInvariant();
            if (normalizedQuery.Length < 2)
            {
                return new List<UserInviteSuggestionDTO>();
            }

            limit = Math.Clamp(limit, 1, 20);
            var normalizedScope = (scope ?? string.Empty).Trim().ToLowerInvariant();

            var usersQuery = _context.Users
                .AsNoTracking()
                .Where(u => u.UserUId != requesterUId)
                .Where(u => u.StatusAccount != "Locked")
                .Where(u =>
                    u.Email.ToLower().Contains(normalizedQuery) ||
                    u.UserName.ToLower().Contains(normalizedQuery));

            if (normalizedScope == "board")
            {
                if (string.IsNullOrWhiteSpace(workspaceId) || string.IsNullOrWhiteSpace(boardId))
                {
                    return new List<UserInviteSuggestionDTO>();
                }

                var boardBelongsToWorkspace = await _context.Boards
                    .AsNoTracking()
                    .AnyAsync(b => b.BoardUId == boardId && b.WorkspaceUId == workspaceId);
                if (!boardBelongsToWorkspace)
                {
                    return new List<UserInviteSuggestionDTO>();
                }

                var workspace = await _context.Workspaces
                    .AsNoTracking()
                    .FirstOrDefaultAsync(w => w.WorkspaceUId == workspaceId);
                if (workspace == null)
                {
                    return new List<UserInviteSuggestionDTO>();
                }

                var workspaceMemberRoles = await _context.WorkspaceMembers
                    .AsNoTracking()
                    .Where(wm => wm.WorkspaceUId == workspaceId)
                    .Select(wm => new { wm.UserUId, wm.Role })
                    .ToListAsync();

                var allowedUserIds = workspaceMemberRoles
                    .Select(wm => wm.UserUId)
                    .Append(workspace.OwnerUId)
                    .Where(id => !string.IsNullOrWhiteSpace(id))
                    .Distinct()
                    .ToHashSet();

                var existingBoardMemberIds = await _context.BoardMembers
                    .AsNoTracking()
                    .Where(bm => bm.BoardUId == boardId)
                    .Select(bm => bm.UserUId)
                    .ToListAsync();
                var existingBoardMemberSet = existingBoardMemberIds.ToHashSet();

                var users = await usersQuery
                    .Where(u => allowedUserIds.Contains(u.UserUId))
                    .Where(u => !existingBoardMemberSet.Contains(u.UserUId))
                    .OrderBy(u => u.UserName)
                    .ThenBy(u => u.Email)
                    .Take(limit)
                    .ToListAsync();

                var roleLookup = workspaceMemberRoles.ToDictionary(wm => wm.UserUId, wm => wm.Role);
                return users.Select(u => new UserInviteSuggestionDTO
                {
                    UserUId = u.UserUId,
                    UserName = u.UserName,
                    Email = u.Email,
                    AvatarUrl = u.AvatarUrl,
                    WorkspaceRole = u.UserUId == workspace.OwnerUId ? "Owner" : roleLookup.GetValueOrDefault(u.UserUId)
                }).ToList();
            }

            if (normalizedScope == "workspace")
            {
                if (!string.IsNullOrWhiteSpace(workspaceId))
                {
                    var existingWorkspaceMemberIds = await _context.WorkspaceMembers
                        .AsNoTracking()
                        .Where(wm => wm.WorkspaceUId == workspaceId)
                        .Select(wm => wm.UserUId)
                        .ToListAsync();
                    var workspaceOwnerId = await _context.Workspaces
                        .AsNoTracking()
                        .Where(w => w.WorkspaceUId == workspaceId)
                        .Select(w => w.OwnerUId)
                        .FirstOrDefaultAsync();
                    var excludedIds = existingWorkspaceMemberIds
                        .Append(workspaceOwnerId)
                        .Where(id => !string.IsNullOrWhiteSpace(id))
                        .ToHashSet();
                    usersQuery = usersQuery.Where(u => !excludedIds.Contains(u.UserUId));
                }

                return await usersQuery
                    .OrderBy(u => u.UserName)
                    .ThenBy(u => u.Email)
                    .Take(limit)
                    .Select(u => new UserInviteSuggestionDTO
                    {
                        UserUId = u.UserUId,
                        UserName = u.UserName,
                        Email = u.Email,
                        AvatarUrl = u.AvatarUrl
                    })
                    .ToListAsync();
            }

            return new List<UserInviteSuggestionDTO>();
        }


        public async Task<string> ResendVerificationCodeAsync(string email)
        {
            if (string.IsNullOrEmpty(email))
                throw new ArgumentException("Email không hợp lệ.");

            //  Tìm user theo email
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null)
                throw new Exception("Không tìm thấy tài khoản.");

            if (user.IsEmailVerified && user.StatusAccount != "Locked")
                return "Tài khoản này đã được xác thực trước đó.";

            //  Sinh mã xác thực mới
            string code = new Random().Next(100000, 999999).ToString();

            //  Cập nhật mã hash và thời gian hết hạn
            user.VerificationTokenHash = BCrypt.Net.BCrypt.HashPassword(code);
            user.VerificationTokenExpiresAt = DateTime.UtcNow.AddMinutes(5);


            _context.Users.Update(user);

            var existingOtp = await _context.UserOtps.FindAsync(user.UserUId);
            if (existingOtp != null) _context.UserOtps.Remove(existingOtp);

            await _context.UserOtps.AddAsync(new UserOtp
            {
                UserUId = user.UserUId,
                OtpCode = code,
                ExpiresAt = DateTime.UtcNow.AddMinutes(5)
            });

            await _context.SaveChangesAsync();

            // Gửi mail
            try 
            {
                await _emailService.SendVerificationEmailAsync(email, code);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ResendVerificationCodeAsync] Error sending email: {ex.Message}");
            }

            return " Mã xác thực mới đã được gửi tới email của bạn (có hiệu lực trong 5 phút).";
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

            if (user.IsEmailVerified && user.StatusAccount != "Locked") return new AuthResponse { Message = "Email already verified!" };

            var now = DateTime.UtcNow;

            if (user.VerificationTokenExpiresAt == null || now >= user.VerificationTokenExpiresAt.Value.AddMinutes(-4.5))
            {
                await ResendVerificationCodeAsync(email);
                return new AuthResponse
                {
                    Message = "Mã xác thực đã hết hạn và đã được gửi lại tự động.",
                    Email = email,
                    requiresVerification = true,
                    ExpiresInSeconds = 30
                };
            }

            var nextAllowedResendTime = user.VerificationTokenExpiresAt.Value.AddMinutes(-4.5);
            var remainingWait = (int)(nextAllowedResendTime - now).TotalSeconds;

            return new AuthResponse
            {
                Message = "Mã xác thực vẫn còn hiệu lực.",
                Email = email,
                requiresVerification = true,
                ExpiresInSeconds = remainingWait > 0 ? remainingWait : 0
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
            try
            {
                var lockToken = Guid.NewGuid().ToString("N");
                var lockKey = $"LockAccount_{lockToken}";
                _memoryCache.Set(lockKey, $"{user.UserUId}|{user.Email}", TimeSpan.FromDays(3));

                await _emailService.SendChangePasswordNotificationEmailAsync(user.Email, lockToken);
                _logger.LogInformation($"[ChangePassword] Notification email sent to: {user.Email}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"[ChangePassword] Failed to send notification email: {ex.Message}");
            }

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
        public async Task<object> CheckChangeEmailAsync(string userUId, string newEmail, string currentPassword)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy tài khoản.");

            if (!BCrypt.Net.BCrypt.Verify(currentPassword, user.PasswordHash))
                throw new UnauthorizedAccessException("Mật khẩu hiện tại không chính xác.");

            if (await _context.Users.AnyAsync(u => u.Email == newEmail))
                throw new InvalidOperationException("Email này đã được sử dụng bởi tài khoản khác.");

            return new { success = true, is2FAEnabled = user.IsTwoFactorEnabled };
        }

        public async Task<bool> SendChangeEmailOtpAsync(string userUId, string newEmail, string currentPassword, string? twoFactorCode)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy tài khoản.");

            if (!BCrypt.Net.BCrypt.Verify(currentPassword, user.PasswordHash))
                throw new UnauthorizedAccessException("Mật khẩu hiện tại không chính xác.");

            if (await _context.Users.AnyAsync(u => u.Email == newEmail))
                throw new InvalidOperationException("Email này đã được sử dụng bởi tài khoản khác.");

            if (user.IsTwoFactorEnabled)
            {
                if (string.IsNullOrWhiteSpace(twoFactorCode))
                    throw new ArgumentException("Vui lòng nhập mã xác thực 2FA.");

                if (string.IsNullOrEmpty(user.TwoFactorSecret))
                    throw new InvalidOperationException("Tài khoản chưa thiết lập khóa bí mật 2FA.");

                var secretBytes = Base32Encoding.ToBytes(user.TwoFactorSecret);
                var totp = new Totp(secretBytes, step: 30, totpSize: 6);
                var window = new VerificationWindow(previous: 1, future: 1);

                bool isValid = totp.VerifyTotp(twoFactorCode, out long timeStepMatched, window);
                if (!isValid)
                    throw new UnauthorizedAccessException("Mã 2FA không hợp lệ.");
            }

            var otpCode = new Random().Next(100000, 999999).ToString();
            var cacheKey = $"ChangeEmailOtp_{userUId}_{newEmail}";
            _memoryCache.Set(cacheKey, otpCode, TimeSpan.FromMinutes(15));

            var lockToken = Guid.NewGuid().ToString("N");
            var lockKey = $"LockAccount_{lockToken}";
            _memoryCache.Set(lockKey, $"{userUId}|{user.Email}", TimeSpan.FromDays(3));

            try
            {
                await _emailService.SendEmailChangeOtpAsync(newEmail, otpCode);
                await _emailService.SendEmailChangeWarningAsync(user.Email, newEmail, lockToken);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Lỗi gửi email thay đổi địa chỉ email: {ex.Message}");
                throw new InvalidOperationException($"Không thể gửi email: {ex.Message}");
            }

            return true;
        }

        public async Task<bool> ConfirmChangeEmailAsync(string userUId, string newEmail, string otpCode)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy tài khoản.");

            var cacheKey = $"ChangeEmailOtp_{userUId}_{newEmail}";
            if (!_memoryCache.TryGetValue(cacheKey, out string? cachedOtp) || cachedOtp != otpCode)
            {
                throw new UnauthorizedAccessException("Mã OTP không chính xác hoặc đã hết hạn.");
            }

            user.Email = newEmail;
            user.IsEmailVerified = true;
            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            _memoryCache.Remove(cacheKey);

            return true;
        }

        public async Task<bool> LockAccountAsync(string token)
        {
            var lockKey = $"LockAccount_{token}";
            if (!_memoryCache.TryGetValue(lockKey, out string? cachedData))
            {
                throw new UnauthorizedAccessException("Link khóa tài khoản không hợp lệ hoặc đã hết hạn.");
            }

            var parts = cachedData?.Split('|');
            if (parts == null || parts.Length != 2) return false;

            var userUId = parts[0];
            var oldEmail = parts[1];

            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user != null)
            {
                // Restore old email and lock account
                user.Email = oldEmail;
                user.StatusAccount = "Locked";
                
                // Revoke all sessions
                var sessions = await _context.UserSessions.Where(s => s.UserUId == userUId).ToListAsync();
                foreach (var session in sessions)
                {
                    session.IsRevoked = true;
                }
                _context.UserSessions.UpdateRange(sessions);
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
                
                // Thu hồi tất cả session hoàn tất, giờ gửi SignalR
                await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                    .SendAsync("AccountLocked", new { message = "Tài khoản của bạn đã bị khóa để bảo mật." });

                _memoryCache.Remove(lockKey);
                return true;
            }
            return false;
        }
    }
}
