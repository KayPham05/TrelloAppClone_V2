using System.ComponentModel.DataAnnotations;

namespace TodoAppAPI.DTOs
{
    public class ChangePasswordRequest
    {
        [Required(ErrorMessage = "Mật khẩu cũ không được bỏ trống.")]
        public string OldPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu mới không được bỏ trống.")]
        [MinLength(6, ErrorMessage = "Mật khẩu mới phải có ít nhất 6 ký tự.")]
        public string NewPassword { get; set; } = string.Empty;

        /// <summary>
        /// Mã TOTP 6 số từ Google Authenticator. Null/rỗng nếu user chưa bật 2FA.
        /// </summary>
        public string? TwoFactorCode { get; set; }
    }
}
