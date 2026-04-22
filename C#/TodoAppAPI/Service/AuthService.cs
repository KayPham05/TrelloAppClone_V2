using System.Web;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;

namespace TodoAppAPI.Service
{
    public class AuthService : IAuthService
    {
        private readonly TodoDbContext _context;
        private readonly IJwtService _jwtService;
        private readonly EmailService _emailService;

        public AuthService(TodoDbContext context, IJwtService jwtService, EmailService emailService)
        {
            _context = context;
            _jwtService = jwtService;
            _emailService = emailService;
        }

        //Register (keep email logic)
        public async Task<AuthResponse> RegisterAsync(string userName, string email, string password)
        {
            if (await _context.Users.AnyAsync(u => u.Email == email))
                return new AuthResponse { Message = "Email is already in use!" , IsMember = true};

            var hashed = BCrypt.Net.BCrypt.HashPassword(password);
            var code = new Random().Next(100000, 999999).ToString();

            var user = new User
            {
                UserUId = Guid.NewGuid().ToString(),
                UserName = userName,
                Email = email,
                PasswordHash = hashed,
                VerificationTokenHash = BCrypt.Net.BCrypt.HashPassword(code),
                VerificationTokenExpiresAt = DateTime.UtcNow.AddMinutes(5),
                RoleId = 2,
                StatusAccount = "Pending"
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            await _emailService.SendVerificationEmailAsync(email, code);

            return new AuthResponse
            {
                Message = "Registration successful! Please check your email to verify your account.",
                Email = email
            };
        }

        // Login + 2FA
        public async Task<AuthResponse> LoginAsync(string email, string password)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
                return new AuthResponse { Message = "Account not found!" };

            if (!BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
                return new AuthResponse { Message = "Incorrect password!" };

            // Check email verification BEFORE checking 2FA
            if (!user.IsEmailVerified)
            {
                return new AuthResponse
                {
                    Message = "Email has not been verified.",
                    Email = user.Email,
                    requiresVerification = true
                };
            }

            // 2FA check
            if (user.IsTwoFactorEnabled)
            {
                string code = new Random().Next(100000, 999999).ToString();
                await _emailService.SendTwoFactorOtpEmailAsync(user.Email, code);

                var existing = await _context.UserOtps.FindAsync(user.UserUId);
                if (existing != null) _context.UserOtps.Remove(existing);

                await _context.UserOtps.AddAsync(new UserOtp
                {
                    UserUId = user.UserUId,
                    OtpCode = code,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(2)
                });

                await _context.SaveChangesAsync();

                return new AuthResponse
                {
                    UserUId = user.UserUId,
                    requires2FA = true,
                    Email = user.Email,
                    Message = "OTP has been sent."
                };
            }

            // Login success
            user.StatusAccount = "Login";
            await _context.SaveChangesAsync();

            return await GenerateTokensAndSession(user);
        }

        // Verify OTP
        public async Task<AuthResponse> VerifyOtpAsync(string email, string otp)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null) return new AuthResponse { Message = "Account not found!" };

            var otpRec = await _context.UserOtps.FindAsync(user.UserUId);
            if (otpRec == null || otpRec.ExpiresAt < DateTime.UtcNow || otpRec.OtpCode != otp)
                return new AuthResponse { Message = "Invalid or expired OTP!" };

            _context.UserOtps.Remove(otpRec);
            await _context.SaveChangesAsync();

            return await GenerateTokensAndSession(user);
        }

        // Google login
        public async Task<AuthResponse> GoogleLoginAsync(string email, string name)
        {
            if (string.IsNullOrEmpty(email))
                return new AuthResponse { Message = "Invalid Google email!" };

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                user = new User
                {
                    UserUId = Guid.NewGuid().ToString(),
                    UserName = string.IsNullOrWhiteSpace(name)
                        ? email.Split('@')[0]
                        : name.Trim(),
                    Email = email,
                    IsEmailVerified = true,
                    RoleId = 2,
                    Provider = "Google",
                    CreatedAt = DateTime.UtcNow,
                    StatusAccount = "Login"
                };

                await _context.Users.AddAsync(user);
                await _context.SaveChangesAsync();
            }
            else
            {
                user.StatusAccount = "Login";

                if (!user.IsEmailVerified)
                {
                    user.IsEmailVerified = true;
                }
                await _context.SaveChangesAsync();
            }

            return await GenerateTokensAndSession(user);
        }

        // Refresh
        public async Task<string?> RefreshAccessTokenAsync(string refreshToken)
        {
            var decodedToken = HttpUtility.UrlDecode(refreshToken);
            decodedToken = decodedToken.Replace(" ", "+");

            Console.WriteLine($"Decoded refreshToken (normalized): {decodedToken}");

            var session = await _context.UserSessions.FirstOrDefaultAsync(s => s.RefreshToken == refreshToken);

            if (session == null || session.IsRevoked || session.ExpiresAt < DateTime.UtcNow)
                return null;

            var user = await _context.Users.FindAsync(session.UserUId);
            return _jwtService.GenerateAccessToken(user);
        }

        // Logout
        public async Task LogoutAsync(string refreshToken)
        {
            var session = await _context.UserSessions.FirstOrDefaultAsync(s => s.RefreshToken == refreshToken);
            if (session != null)
            {
                session.IsRevoked = true;
                await _context.SaveChangesAsync();
            }
        }

        // Helper
        private async Task<AuthResponse> GenerateTokensAndSession(User user)
        {
            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();

            var oldSession = await _context.UserSessions.FirstOrDefaultAsync(s => s.UserUId == user.UserUId);

            if (oldSession != null)
            {
                oldSession.RefreshToken = refreshToken;
                oldSession.ExpiresAt = DateTime.UtcNow.AddDays(7);
                oldSession.IsRevoked = false;
                _context.UserSessions.Update(oldSession);
            }
            else
            {
                await _context.UserSessions.AddAsync(new UserSession
                {
                    UserUId = user.UserUId,
                    RefreshToken = refreshToken,
                    ExpiresAt = DateTime.UtcNow.AddDays(7),
                    IsRevoked = false
                });
            }

            await _context.SaveChangesAsync();

            return new AuthResponse
            {
                Message = "Login successful!",
                UserUId = user.UserUId,
                Token = accessToken,
                Email = user.Email,
                UserName = user.UserName,
                Bio = user.Bio,
                RefreshToken = refreshToken,
            };
        }

        public async Task<UserSession?> GetUserSessionByUserId(string userUId)
        {
            return await _context.UserSessions.AsNoTracking().FirstOrDefaultAsync(s => s.UserUId == userUId);
        }

        public async Task<bool> SendTwoFactorOtpAsync(string email)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null) return false;

            string code = new Random().Next(100000, 999999).ToString();

            await _emailService.SendTwoFactorOtpEmailAsync(email, code);

            var existing = await _context.UserOtps.FindAsync(user.UserUId);
            if (existing != null) _context.UserOtps.Remove(existing);

            await _context.UserOtps.AddAsync(new UserOtp
            {
                UserUId = user.UserUId,
                OtpCode = code,
                ExpiresAt = DateTime.UtcNow.AddMinutes(2)
            });

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<VerifyTwoFactorResponse> VerifyTwoFactorSetupAsync(string email, string otp)
        {
            Console.WriteLine($"[DEBUG] VerifyTwoFactorSetupAsync - Email: {email}, OTP: {otp}");

            var user = await _context.Users.FirstOrDefaultAsync(x => x.Email == email);
            if (user == null)
            {
                Console.WriteLine($"[ERROR] User not found: {email}");
                return new VerifyTwoFactorResponse
                {
                    Message = "Account not found!",
                    IsTwoFactorEnabled = false
                };
            }

            Console.WriteLine($"[DEBUG] User found: {user.UserUId}");

            var entry = await _context.UserOtps.FindAsync(user.UserUId);

            if (entry == null)
            {
                Console.WriteLine($"[ERROR] No OTP record found");
                return new VerifyTwoFactorResponse
                {
                    Message = "OTP code not found. Please request a new one!",
                    IsTwoFactorEnabled = false
                };
            }

            Console.WriteLine($"[DEBUG] Stored: {entry.OtpCode}, Expires: {entry.ExpiresAt}");

            if (entry.ExpiresAt < DateTime.UtcNow)
            {
                Console.WriteLine("[ERROR] OTP expired");
                _context.UserOtps.Remove(entry);
                await _context.SaveChangesAsync();

                return new VerifyTwoFactorResponse
                {
                    Message = "OTP has expired!",
                    IsTwoFactorEnabled = false
                };
            }

            if (entry.OtpCode != otp)
            {
                Console.WriteLine("[ERROR] OTP mismatch");
                return new VerifyTwoFactorResponse
                {
                    Message = "Incorrect OTP!",
                    IsTwoFactorEnabled = false
                };
            }

            Console.WriteLine("[SUCCESS] OTP verified");

            _context.UserOtps.Remove(entry);
            await _context.SaveChangesAsync();

            return new VerifyTwoFactorResponse
            {
                Message = "Verification successful!",
                IsTwoFactorEnabled = true
            };
        }
    }
}
