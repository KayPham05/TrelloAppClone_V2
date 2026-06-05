using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TodoAppAPI.Hubs;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/users")]
    [ApiController]
    public class UserController : ControllerBase
    {
        public readonly IUserService _userService;
        private readonly IAuthService _authService;
        private readonly ICloudinaryService _cloudinaryService;
        private readonly ILogger<UserController> _logger;
        private readonly IHubContext<NotificationHub> _notificationHubContext;

        public UserController(IUserService userService, IAuthService authService, ICloudinaryService cloudinaryService, ILogger<UserController> logger, IHubContext<NotificationHub> notificationHubContext)
        {
            _userService = userService;
            _authService = authService;
            _cloudinaryService = cloudinaryService;
            _logger = logger;
            _notificationHubContext = notificationHubContext;
        }


        [HttpGet("get-by-email")]
        public async Task<IActionResult> GetUserByEmail([FromQuery] string email)
        {
            if (string.IsNullOrEmpty(email))
                return BadRequest("Email không hợp lệ");

            var user = await _userService.GetUserByEmail(email);

            if (user == null)
                return NotFound("Không tìm thấy user với email này");

            return Ok(user);
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchUserByEmail([FromQuery] string email)
        {
            return await GetUserByEmail(email);
        }

        [HttpPost("AddBio")]
        public async Task<IActionResult> AddBio([FromQuery] string userUId, [FromQuery] string Bio)
        {
            if (userUId == null) return BadRequest("userUId is null");
            var result = await _userService.AddBioByUserUId(userUId, Bio);
            if (!result)
            {
                return BadRequest("Thêm không thành công");
            }
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId)).SendAsync("ProfileUpdated", new { userUId, bio = Bio });
            return Ok("Thêm thành công");
        }
        [HttpPost("AddUsername")]
        public async Task<IActionResult> AddUsername([FromQuery] string userUId, [FromQuery] string username)
        {
            if (userUId == null || username == null) return BadRequest("userUId is null or username is null");
            var result = await _userService.AddUserUSerName(userUId, username);
            if (!result)
            {
                return BadRequest("Thêm không thành công");
            }
            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId)).SendAsync("ProfileUpdated", new { userUId, userName = username });
            return Ok("Thêm thành công");
        }
        [HttpGet("GetBio")]
        public async Task<IActionResult> GetBio([FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest("userUId is null");
            var bio = await _userService.GetBioByUserUId(userUId);
            return Ok(new { bio = bio ?? "" });
        }
        [HttpGet("GetUsername")]
        public async Task<IActionResult> GetUsername([FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId)) return BadRequest("userUId is null");
            var userName = await _userService.GetUserUserName(userUId);
            return Ok(new { userName = userName ?? "" });
        }

        [AllowAnonymous]
        [HttpPost("verify-code")]
        public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeRequest req)
        {
            if (string.IsNullOrEmpty(req.Email) || string.IsNullOrEmpty(req.Code))
                return BadRequest("Thiếu thông tin xác thực.");

            //  Lấy user theo email
            var user = await _userService.GetUserByEmail(req.Email);
            if (user == null)
                return NotFound("Không tìm thấy tài khoản.");

            //  Nếu đã xác thực và KHÔNG bị khóa thì tạo token và trả về luôn
            if (!user.IsEmailVerified || user.StatusAccount == "Locked")
            {
                //  Kiểm tra hết hạn mã
                if (user.VerificationTokenExpiresAt == null || user.VerificationTokenExpiresAt < DateTime.UtcNow)
                    return BadRequest("Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới.");

                //  Kiểm tra mã hợp lệ
                bool valid = BCrypt.Net.BCrypt.Verify(req.Code, user.VerificationTokenHash);
                if (!valid)
                    return BadRequest("Mã xác thực không hợp lệ.");

                //  Cập nhật trạng thái xác thực
                user.IsEmailVerified = true;
                user.VerificationTokenHash = null;
                user.VerificationTokenExpiresAt = null;
                user.StatusAccount = "Login"; // Unlock account
                await _userService.UpdateAsync(user);
            }

            // Tạo access token + refresh token + session
            var authResponse = await _authService.GenerateTokensAndSessionPublic(user);

            // Set refreshToken cookie (giống login)
            var session = await _authService.GetUserSessionByUserId(user.UserUId);
            if (session != null)
            {
                Response.Cookies.Append("refreshToken", session.RefreshToken, new CookieOptions
                {
                    HttpOnly = true,
                    Secure = false,
                    SameSite = SameSiteMode.Lax,
                    Path = "/",
                    Expires = session.ExpiresAt
                });
            }

            return Ok(authResponse);
        }


        [AllowAnonymous]
        [HttpPost("resend-code")]
        public async Task<IActionResult> ResendVerificationCode([FromQuery] string email)
        {
            try 
            {
                var resultMessage = await _userService.ResendVerificationCodeAsync(email);
                return Ok(resultMessage);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return NotFound(ex.Message);
            }
        }

        [AllowAnonymous]
        [HttpGet("get-verification-status")]
        public async Task<IActionResult> GetVerificationStatus([FromQuery] string email)
        {
            if (string.IsNullOrEmpty(email))
                return BadRequest("Email không hợp lệ");

            try
            {
                var result = await _userService.GetVerificationStatusAndResendIfExpiredAsync(email);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("toggle-2fa")]
        public async Task<IActionResult> ToggleTwoFactor([FromQuery] string userUId, [FromQuery] bool enabled)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId không hợp lệ" });

            var ok = await _userService.ToggleTwoFactorAsync(userUId, enabled);

            if (!ok)
                return BadRequest(new { message = "Không tìm thấy user." });

            return Ok(new { message = enabled ? "Đã bật 2FA" : "Đã tắt 2FA" });
        }

        /// <summary>
        /// POST v1/api/users/change-password
        /// Atomic Request: Đổi mật khẩu + xác thực 2FA (nếu bật) trong 1 API call duy nhất.
        /// </summary>
        [Authorize]
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            // Validate Model (kiểm tra [Required], [MinLength(6)])
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Validate thêm trên Controller để đảm bảo an toàn
            if (request.NewPassword.Length < 6)
                return BadRequest(new { message = "Mật khẩu mới phải có ít nhất 6 ký tự." });

            // Lấy userUId từ JWT Claims (custom claim "UserUId" được set trong JwtService)
            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrEmpty(userUId))
                return Unauthorized(new { message = "Không xác định được người dùng. Vui lòng đăng nhập lại." });

            try
            {
                var result = await _userService.ChangePasswordAsync(
                    userUId,
                    request.OldPassword,
                    request.NewPassword,
                    request.TwoFactorCode
                );

                _logger.LogInformation($"[ChangePassword] Success for user: {userUId}");
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[ChangePassword] Unexpected error: {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi khi đổi mật khẩu. Vui lòng thử lại." });
            }
        }

        [Authorize]
        [HttpPut("update-profile")]
        public async Task<IActionResult> UpdateProfile([FromForm] UpdateProfileRequest request)
        {
            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrEmpty(userUId))
                return Unauthorized(new { message = "Không xác định được người dùng." });

            var user = await _userService.GetByIdAsync(userUId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng." });

            if (!string.IsNullOrEmpty(request.UserName))
            {
                user.UserName = request.UserName;
            }

            if (request.Bio != null)
            {
                user.Bio = request.Bio;
            }

            if (request.Avatar != null)
            {
                var uploadResult = await _cloudinaryService.UploadFileAsync(request.Avatar);
                if (uploadResult != null)
                {
                    user.AvatarUrl = uploadResult.Value.Url;
                }
            }

            await _userService.UpdateAsync(user);

            await _notificationHubContext.Clients.Group(NotificationHub.UserGroup(userUId))
                .SendAsync("ProfileUpdated", new { userUId, userName = user.UserName, avatarUrl = user.AvatarUrl, bio = user.Bio });

            return Ok(new
            {
                message = "Cập nhật thông tin thành công.",
                userName = user.UserName,
                avatarUrl = user.AvatarUrl
            });
        }

        [Authorize]
        [HttpPost("check-change-email")]
        public async Task<IActionResult> CheckChangeEmail([FromBody] CheckChangeEmailRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrEmpty(userUId))
                return Unauthorized(new { message = "Không xác định được người dùng." });

            try
            {
                var result = await _userService.CheckChangeEmailAsync(userUId, request.NewEmail, request.CurrentPassword);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[CheckChangeEmail] Error: {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi." });
            }
        }

        [Authorize]
        [HttpPost("send-change-email-otp")]
        public async Task<IActionResult> SendChangeEmailOtp([FromBody] SendChangeEmailOtpRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrEmpty(userUId))
                return Unauthorized(new { message = "Không xác định được người dùng." });

            try
            {
                await _userService.SendChangeEmailOtpAsync(userUId, request.NewEmail, request.CurrentPassword, request.TwoFactorCode);
                return Ok(new { message = "Mã xác nhận đã được gửi đến email mới của bạn." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[SendChangeEmailOtp] Error: {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi." });
            }
        }

        [Authorize]
        [HttpPost("confirm-change-email")]
        public async Task<IActionResult> ConfirmChangeEmail([FromBody] ConfirmChangeEmailRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userUId = User.FindFirstValue("UserUId");
            if (string.IsNullOrEmpty(userUId))
                return Unauthorized(new { message = "Không xác định được người dùng." });

            try
            {
                await _userService.ConfirmChangeEmailAsync(userUId, request.NewEmail, request.OtpCode);
                return Ok(new { message = "Đổi email thành công." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[ConfirmChangeEmail] Error: {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi." });
            }
        }

        [AllowAnonymous]
        [HttpGet("lock-account")]
        public async Task<IActionResult> LockAccount([FromQuery] string token)
        {
            if (string.IsNullOrEmpty(token))
                return BadRequest(new { message = "Token không hợp lệ." });

            try
            {
                var result = await _userService.LockAccountAsync(token);
                if (result)
                {
                    var html = @"
                        <html>
                            <head>
                                <meta charset='UTF-8'>
                                <title>Tài khoản đã bị khóa</title>
                            </head>
                            <body style='text-align:center; padding: 50px; font-family: Arial, sans-serif; background-color: #f9f9f9;'>
                                <div style='background-color: white; padding: 30px; border-radius: 10px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'>
                                    <h1 style='color: #d32f2f;'>Tài khoản đã bị khóa an toàn</h1>
                                    <p style='color: #555; font-size: 16px; margin-bottom: 20px;'>Tài khoản của bạn đã được khóa ngay lập tức để bảo vệ khỏi truy cập trái phép.</p>
                                    <p style='color: #777; font-size: 14px;'>Để mở khóa, vui lòng mở ứng dụng Trello Clone, tiến hành Đăng nhập và nhập mã OTP xác thực được gửi về email gốc của bạn.</p>
                                </div>
                            </body>
                        </html>";
                    return Content(html, "text/html");
                }
                
                var errorHtml = @"
                        <html>
                            <head>
                                <meta charset='UTF-8'>
                                <title>Lỗi khóa tài khoản</title>
                            </head>
                            <body style='text-align:center; padding: 50px; font-family: Arial, sans-serif; background-color: #f9f9f9;'>
                                <div style='background-color: white; padding: 30px; border-radius: 10px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'>
                                    <h1 style='color: #f57c00;'>Không thể khóa tài khoản</h1>
                                    <p style='color: #555; font-size: 16px;'>Đường dẫn không hợp lệ hoặc đã hết hạn.</p>
                                </div>
                            </body>
                        </html>";
                return Content(errorHtml, "text/html");
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[LockAccount] Error: {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi." });
            }
        }
    }
}
