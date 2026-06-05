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
        /// BÆ°á»›c 2: Sinh SecretKey Base32, lÆ°u vÃ o Cache táº¡m (TTL 15 phÃºt), táº¡o QR URI.
        /// CHÆ¯A lÆ°u vÃ o DB, CHÆ¯A báº­t Is2FAEnabled.
        /// </summary>
        public async Task<Setup2FAResponse> Setup2FAAsync(string userUId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("KhÃ´ng tÃ¬m tháº¥y tÃ i khoáº£n.");

            if (user.IsTwoFactorEnabled)
                throw new InvalidOperationException("XÃ¡c thá»±c 2 yáº¿u tá»‘ Ä‘Ã£ Ä‘Æ°á»£c báº­t trÆ°á»›c Ä‘Ã³.");

            // Sinh SecretKey ngáº«u nhiÃªn 20 bytes â†’ Base32
            var secretBytes = KeyGeneration.GenerateRandomKey(20);
            var secretBase32 = Base32Encoding.ToString(secretBytes);

            // LÆ°u vÃ o Cache táº¡m vá»›i TTL 15 phÃºt
            var cacheKey = $"Temp2FASecret_{userUId}";
            _cache.Set(cacheKey, secretBase32, TimeSpan.FromMinutes(15));
            _logger.LogInformation($"[2FA Setup] Temp secret cached for user: {userUId}");

            // Táº¡o chuá»—i URI chuáº©n cho Google Authenticator
            var qrUri = $"otpauth://totp/Kabo:{Uri.EscapeDataString(user.Email)}?secret={secretBase32}&issuer=Kabo";

            return new Setup2FAResponse
            {
                SecretKey = secretBase32,
                QrUri = qrUri
            };
        }

        /// <summary>
        /// BÆ°á»›c 5: Verify mÃ£ TOTP 6 sá»‘, chá»‘ng Replay Attack, kÃ­ch hoáº¡t 2FA, sinh backup codes.
        /// </summary>
        public async Task<Enable2FAResponse> Enable2FAAsync(string userUId, string code)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserUId == userUId);
            if (user == null)
                throw new KeyNotFoundException("KhÃ´ng tÃ¬m tháº¥y tÃ i khoáº£n.");

            // Láº¥y Temp2FASecret tá»« Cache
            var cacheKey = $"Temp2FASecret_{userUId}";
            if (!_cache.TryGetValue(cacheKey, out string? secretBase32) || string.IsNullOrEmpty(secretBase32))
                throw new InvalidOperationException("PhiÃªn thiáº¿t láº­p 2FA Ä‘Ã£ háº¿t háº¡n. Vui lÃ²ng thá»­ láº¡i.");

            // Chá»‘ng Replay Attack: kiá»ƒm tra mÃ£ Ä‘Ã£ dÃ¹ng trong 30s gáº§n Ä‘Ã¢y
            var replayCacheKey = $"2FAUsedCode_{userUId}_{code}";
            if (_cache.TryGetValue(replayCacheKey, out _))
                throw new InvalidOperationException("MÃ£ xÃ¡c thá»±c Ä‘Ã£ Ä‘Æ°á»£c sá»­ dá»¥ng. Vui lÃ²ng chá» mÃ£ má»›i.");

            // Verify mÃ£ TOTP báº±ng Otp.NET (cho phÃ©p +-30s time drift = +-1 step)
            var secretBytes = Base32Encoding.ToBytes(secretBase32);
            var totp = new Totp(secretBytes, step: 30, totpSize: 6);
            var window = new VerificationWindow(previous: 1, future: 1);

            bool isValid = totp.VerifyTotp(code, out long timeStepMatched, window);

            if (!isValid)
            {
                _logger.LogWarning($"[2FA Enable] Invalid TOTP code for user: {userUId}");
                throw new UnauthorizedAccessException("MÃ£ xÃ¡c thá»±c khÃ´ng há»£p lá»‡.");
            }

            _logger.LogInformation($"[2FA Enable] TOTP verified for user: {userUId}, timeStep: {timeStepMatched}");

            // LÆ°u mÃ£ Ä‘Ã£ dÃ¹ng vÃ o cache Ä‘á»ƒ chá»‘ng Replay Attack (TTL 30s)
            _cache.Set(replayCacheKey, true, TimeSpan.FromSeconds(30));

            // Cáº­p nháº­t DB: lÆ°u SecretKey vÃ  báº­t Is2FAEnabled
            user.TwoFactorSecret = secretBase32;
            user.IsTwoFactorEnabled = true;
            _context.Users.Update(user);

            // XÃ³a Temp2FASecret khá»i Cache
            _cache.Remove(cacheKey);

            // XÃ³a backup codes cÅ© (náº¿u cÃ³)
            var oldCodes = await _context.User2FABackupCodes
                .Where(c => c.UserUId == userUId)
                .ToListAsync();
            if (oldCodes.Any())
                _context.User2FABackupCodes.RemoveRange(oldCodes);

            // Sinh 8 mÃ£ dá»± phÃ²ng (má»—i mÃ£ 8 kÃ½ tá»±, format: XXXX-XXXX)
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
                Message = "XÃ¡c thá»±c 2 yáº¿u tá»‘ Ä‘Ã£ Ä‘Æ°á»£c báº­t thÃ nh cÃ´ng!",
                IsTwoFactorEnabled = true,
                BackupCodes = plainBackupCodes
            };
        }

        /// <summary>
        /// Sinh mÃ£ dá»± phÃ²ng 8 kÃ½ tá»± (A-Z, 0-9), format: XXXX-XXXX
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
