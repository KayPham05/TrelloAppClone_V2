using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IUserService _userService;
        private readonly ITwoFactorService _twoFactorService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, IUserService userService, ITwoFactorService twoFactorService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _userService = userService;
            _twoFactorService = twoFactorService;
            _logger = logger;
        }

        //  AllowAnonymous cho register
        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            try
            {
                var result = await _authService.RegisterAsync(request.UserName, request.Email, request.Password);
                return StatusCode(201, result);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        //  AllowAnonymous cho login
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var result = await _authService.LoginAsync(request.Email, request.Password);

            if (!string.IsNullOrEmpty(result.Token))
            {
                await SetRefreshCookie(result.UserUId);
                return Ok(result);
            }
            else if (result.requiresVerification)
            {
                return StatusCode(403, result);
            }
            else if (result.requires2FA)
            {
                return Ok(result);
            }
            
            return Unauthorized(result);
        }

        //  AllowAnonymous cho Google login
        [AllowAnonymous]
        [HttpPost("Google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            if (string.IsNullOrEmpty(request.AccessToken))
                return BadRequest("Thiếu access_token từ google");

            var httpClient = new HttpClient();
            var googleResponse = await httpClient.GetAsync($"https://www.googleapis.com/oauth2/v2/userinfo?access_token={request.AccessToken}");

            if (!googleResponse.IsSuccessStatusCode)
                return Unauthorized("Access token Google không hợp lệ.");

            var json = await googleResponse.Content.ReadAsStringAsync();
            var googleUser = JsonConvert.DeserializeObject<GoogleUserInfo>(json);

            if (googleUser == null || string.IsNullOrEmpty(googleUser.Email))
                return BadRequest("Không thể lấy thông tin người dùng Google.");

            var user = await _authService.GoogleLoginAsync(googleUser.Email, googleUser.Name);

            if (!string.IsNullOrEmpty(user.Token))
            {
                await SetRefreshCookie(user.UserUId);
                return Ok(user);
            }
            else if (user.requiresVerification)
            {
                return StatusCode(403, user);
            }
            else if (user.requires2FA)
            {
                return Ok(user);
            }

            return Unauthorized(user);
        }

        // AllowAnonymous cho refresh-token
        [AllowAnonymous]
        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest? req = null)
        {
            _logger.LogInformation(" Refresh token request received");

            var refreshToken = req?.RefreshToken;
            
            if (string.IsNullOrEmpty(refreshToken))
            {
                refreshToken = Request.Cookies["refreshToken"];
            }

            _logger.LogInformation($"Cookies: {string.Join(", ", Request.Cookies.Keys)}");
            _logger.LogInformation($"RefreshToken exists: {!string.IsNullOrEmpty(refreshToken)}");

            if (string.IsNullOrEmpty(refreshToken))
            {
                _logger.LogWarning(" No refresh token in cookies or body");
                return Unauthorized(new { message = "Không có refresh token." });
            }

            try
            {
                var accessToken = await _authService.RefreshAccessTokenAsync(refreshToken);

                if (accessToken == null)
                {
                    _logger.LogWarning(" Refresh token invalid or expired");
                    return Unauthorized(new { message = "Refresh token không hợp lệ hoặc đã hết hạn." });
                }

                _logger.LogInformation(" New access token generated successfully");
                return Ok(new { accessToken });
            }
            catch (UnauthorizedAccessException ex) when (ex.Message.StartsWith("ACCOUNT_LOCKED|"))
            {
                var email = ex.Message.Split('|')[1];
                _logger.LogWarning($" Account locked detected on refresh: {email}");

                try
                {
                    await _authService.LoginAsync(email, "DUMMY_PASSWORD_JUST_TO_TRIGGER_OTP_FOR_LOCKED_ACCOUNT");
                }
                catch { } 
                
                return StatusCode(403, new { message = "ACCOUNT_LOCKED", email = email });
            }
        }

        // QUAN TRỌNG: AllowAnonymous cho logout
        [AllowAnonymous]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromQuery] string userUId, [FromBody] RefreshTokenRequest? req = null)
        {
            _logger.LogInformation($" Logout attempt - UserUId: {userUId}");

            var refreshToken = req?.RefreshToken;
            if (string.IsNullOrEmpty(refreshToken))
            {
                refreshToken = Request.Cookies["refreshToken"];
            }
            _logger.LogInformation($" RefreshToken exists: {!string.IsNullOrEmpty(refreshToken)}");

            if (string.IsNullOrEmpty(refreshToken))
            {
                _logger.LogWarning(" No refresh token found, but continuing logout");
                // Vẫn xóa localStorage ở frontend
                return Ok(new { message = "Đã đăng xuất (không có refresh token)." });
            }

            try
            {
                await _userService.UpdateStatusAccount(userUId, "Logout");
                await _authService.LogoutAsync(refreshToken);
                Response.Cookies.Delete("refreshToken");

                _logger.LogInformation(" Logout successful");
                return Ok(new { message = "Đã đăng xuất thành công." });
            }
            catch (Exception ex)
            {
                _logger.LogError($" Logout error: {ex.Message}");
                return StatusCode(500, new { message = "Đã đăng xuất (có lỗi khi xóa session)." });
            }
        }

        //  AllowAnonymous cho verify-otp
        [AllowAnonymous]
        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest req)
        {
            var result = await _authService.VerifyOtpAsync(req.Email, req.Otp);

            if (!string.IsNullOrEmpty(result.Token))
            {
                await SetRefreshCookie(result.UserUId);
                return Ok(result);
            }
            
            return Unauthorized(result);
        }

        private async Task SetRefreshCookie(string userUId)
        {
            var session = await _authService.GetUserSessionByUserId(userUId);
            if (session != null)
            {
                Response.Cookies.Append("refreshToken", session.RefreshToken, new CookieOptions
                {
                    HttpOnly = true,
                    Secure = false,                // false khi local HTTP
                    SameSite = SameSiteMode.Lax,   // Lax cho môi trường local
                    Path = "/",
                    Expires = session.ExpiresAt
                });

                _logger.LogInformation($" Set refreshToken cookie for user: {userUId}");
            }
        }

        [AllowAnonymous]
        [HttpPost("send-2fa-otp")]
        public async Task<IActionResult> Send2FAOtp([FromQuery] string email)
        {
            if (string.IsNullOrEmpty(email))
                return BadRequest(new { message = "Email không hợp lệ" });

            try
            {
                var success = await _authService.SendTwoFactorOtpAsync(email);

                if (!success)
                    return NotFound(new { message = "Không tìm thấy tài khoản" });

                return Ok(new { message = "Mã OTP đã được gửi về email" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Send 2FA OTP error: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
        }

        //  Verify OTP khi BẬT 2FA lần đầu (setup)
        [AllowAnonymous]
        [HttpPost("verify-2fa-setup")]
        public async Task<IActionResult> Verify2FASetup([FromQuery] string email, [FromQuery] string otp)
        {
            _logger.LogInformation($"[DEBUG] verify-2fa-setup called - Email: {email}, OTP: {otp}");

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(otp))
            {
                return BadRequest(new { message = "Thiếu thông tin xác thực" });
            }

            try
            {
                var result = await _authService.VerifyTwoFactorSetupAsync(email, otp);

                if (!result.IsTwoFactorEnabled)
                {
                    return Unauthorized(new { message = result.Message });
                }

                return Ok(new
                {
                    message = result.Message,
                    isTwoFactorEnabled = result.IsTwoFactorEnabled
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"verify-2fa-setup error: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
        }

        // ───────── 2FA TOTP Endpoints ─────────

        /// <summary>
        /// Bước 2: Sinh SecretKey + QR URI cho Google Authenticator.
        /// </summary>
        [HttpGet("2fa/setup")]
        public async Task<IActionResult> Setup2FA([FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId không hợp lệ" });

            try
            {
                var result = await _twoFactorService.Setup2FAAsync(userUId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[2FA Setup Error] {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi khi thiết lập 2FA." });
            }
        }

        /// <summary>
        /// Bước 5: Xác thực mã TOTP 6 số và kích hoạt 2FA.
        /// </summary>
        [HttpPost("2fa/enable")]
        public async Task<IActionResult> Enable2FA([FromQuery] string userUId, [FromBody] Enable2FARequest request)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId không hợp lệ" });

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var result = await _twoFactorService.Enable2FAAsync(userUId, request.Code);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[2FA Enable Error] {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi khi kích hoạt 2FA." });
            }
        }

        [AllowAnonymous]
        [HttpGet("check-otp-status")]
        public async Task<IActionResult> CheckOtpStatus([FromQuery] string email)
        {
            if (string.IsNullOrEmpty(email))
                return BadRequest(new { message = "Email không hợp lệ" });

            try
            {
                var result = await _authService.CheckAndResendVerificationCodeAsync(email);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Check OTP status error: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
        }

        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromQuery] string email)
        {
            if (string.IsNullOrEmpty(email))
                return BadRequest(new { message = "Email không hợp lệ" });

            try
            {
                var success = await _authService.SendForgotPasswordOtpAsync(email);
                if (!success)
                    return NotFound(new { message = "Không thể gửi OTP. Tài khoản không tồn tại hoặc sử dụng Google Login." });

                return Ok(new { message = "Mã OTP khôi phục mật khẩu đã được gửi đến email của bạn." });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Forgot Password error: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
        }

        [AllowAnonymous]
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (string.IsNullOrEmpty(request.Email) || string.IsNullOrEmpty(request.Otp) || string.IsNullOrEmpty(request.NewPassword))
                return BadRequest(new { message = "Thông tin không hợp lệ" });

            try
            {
                var result = await _authService.ResetPasswordAsync(request.Email, request.Otp, request.NewPassword);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Reset Password error: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
