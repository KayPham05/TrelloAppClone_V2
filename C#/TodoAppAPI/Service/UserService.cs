using System.Net.WebSockets;
using System.Text;
using Microsoft.EntityFrameworkCore;
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
        public UserService(TodoDbContext context, EmailService emailService)
        {
            _context = context;
            _emailService = emailService;
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
    }
}
