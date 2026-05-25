using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using OtpNet;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class TwoFactorService : ITwoFactorService
    {
        private readonly TodoDbContext _context;
        private readonly IMemoryCache _cache;
        private readonly ILogger<TwoFactorService> _logger;

        public TwoFactorService(TodoDbContext context, IMemoryCache cache, ILogger<TwoFactorService> logger)
        {
            _context = context;
            _cache = cache;
            _logger = logger;
        }

        /// <summary>
        /// Bước 2: Sinh SecretKey Base32, lưu vào Cache tạm (TTL 15 phút), tạo QR URI.
        /// CHƯA lưu vào DB, CHƯA bật Is2FAEnabled.
        /// </summary>
        public async Task<Setup2FAResponse> Setup2FAAsync(string userUId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy tài khoản.");

            if (user.IsTwoFactorEnabled)
                throw new InvalidOperationException("Xác thực 2 yếu tố đã được bật trước đó.");

            // Sinh SecretKey ngẫu nhiên 20 bytes → Base32
            var secretBytes = KeyGeneration.GenerateRandomKey(20);
            var secretBase32 = Base32Encoding.ToString(secretBytes);

            // Lưu vào Cache tạm với TTL 15 phút
            var cacheKey = $"Temp2FASecret_{userUId}";
            _cache.Set(cacheKey, secretBase32, TimeSpan.FromMinutes(15));
            _logger.LogInformation($"[2FA Setup] Temp secret cached for user: {userUId}");

            // Tạo chuỗi URI chuẩn cho Google Authenticator
            var qrUri = $"otpauth://totp/Trellon:{Uri.EscapeDataString(user.Email)}?secret={secretBase32}&issuer=Trellon";

            return new Setup2FAResponse
            {
                SecretKey = secretBase32,
                QrUri = qrUri
            };
        }

        /// <summary>
        /// Bước 5: Verify mã TOTP 6 số, chống Replay Attack, kích hoạt 2FA, sinh backup codes.
        /// </summary>
        public async Task<Enable2FAResponse> Enable2FAAsync(string userUId, string code)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy tài khoản.");

            // Lấy Temp2FASecret từ Cache
            var cacheKey = $"Temp2FASecret_{userUId}";
            if (!_cache.TryGetValue(cacheKey, out string? secretBase32) || string.IsNullOrEmpty(secretBase32))
                throw new InvalidOperationException("Phiên thiết lập 2FA đã hết hạn. Vui lòng thử lại.");

            // Chống Replay Attack: kiểm tra mã đã dùng trong 30s gần đây
            var replayCacheKey = $"2FAUsedCode_{userUId}_{code}";
            if (_cache.TryGetValue(replayCacheKey, out _))
                throw new InvalidOperationException("Mã xác thực đã được sử dụng. Vui lòng chờ mã mới.");

            // Verify mã TOTP bằng Otp.NET (cho phép +-30s time drift = +-1 step)
            var secretBytes = Base32Encoding.ToBytes(secretBase32);
            var totp = new Totp(secretBytes, step: 30, totpSize: 6);
            var window = new VerificationWindow(previous: 1, future: 1);

            bool isValid = totp.VerifyTotp(code, out long timeStepMatched, window);

            if (!isValid)
            {
                _logger.LogWarning($"[2FA Enable] Invalid TOTP code for user: {userUId}");
                throw new UnauthorizedAccessException("Mã xác thực không hợp lệ.");
            }

            _logger.LogInformation($"[2FA Enable] TOTP verified for user: {userUId}, timeStep: {timeStepMatched}");

            // Lưu mã đã dùng vào cache để chống Replay Attack (TTL 30s)
            _cache.Set(replayCacheKey, true, TimeSpan.FromSeconds(30));

            // Cập nhật DB: lưu SecretKey và bật Is2FAEnabled
            user.TwoFactorSecret = secretBase32;
            user.IsTwoFactorEnabled = true;
            _context.Users.Update(user);

            // Xóa Temp2FASecret khỏi Cache
            _cache.Remove(cacheKey);

            // Xóa backup codes cũ (nếu có)
            var oldCodes = await _context.User2FABackupCodes
                .Where(c => c.UserUId == userUId)
                .ToListAsync();
            if (oldCodes.Any())
                _context.User2FABackupCodes.RemoveRange(oldCodes);

            // Sinh 8 mã dự phòng (mỗi mã 8 ký tự, format: XXXX-XXXX)
            var plainBackupCodes = new List<string>();
            var backupCodeEntities = new List<User2FABackupCode>();

            for (int i = 0; i < 8; i++)
            {
                var rawCode = GenerateBackupCode();
                plainBackupCodes.Add(rawCode);

                backupCodeEntities.Add(new User2FABackupCode
                {
                    UserUId = userUId,
                    CodeHash = BCrypt.Net.BCrypt.HashPassword(rawCode),
                    IsUsed = false
                });
            }

            await _context.User2FABackupCodes.AddRangeAsync(backupCodeEntities);
            await _context.SaveChangesAsync();

            _logger.LogInformation($"[2FA Enable] 2FA activated for user: {userUId}, 8 backup codes generated.");

            return new Enable2FAResponse
            {
                Message = "Xác thực 2 yếu tố đã được bật thành công!",
                IsTwoFactorEnabled = true,
                BackupCodes = plainBackupCodes
            };
        }

        /// <summary>
        /// Sinh mã dự phòng 8 ký tự (A-Z, 0-9), format: XXXX-XXXX
        /// </summary>
        private static string GenerateBackupCode()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var code = new char[8];
            using var rng = RandomNumberGenerator.Create();
            var buffer = new byte[8];
            rng.GetBytes(buffer);

            for (int i = 0; i < 8; i++)
            {
                code[i] = chars[buffer[i] % chars.Length];
            }

            // Format: XXXX-XXXX
            return $"{new string(code, 0, 4)}-{new string(code, 4, 4)}";
        }
    }
}
