using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Google.Apis.Auth;
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
        private readonly IConfiguration _configuration;

        public AuthController(IAuthService authService, IUserService userService, ITwoFactorService twoFactorService, ILogger<AuthController> logger, IConfiguration configuration)
        {
            _authService = authService;
            _userService = userService;
            _twoFactorService = twoFactorService;
            _logger = logger;
            _configuration = configuration;
        }

        //  AllowAnonymous cho register
        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var result = await _authService.RegisterAsync(request.UserName, request.Email, request.Password);
            return Ok(result);
        }

        //  AllowAnonymous cho login
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var result = await _authService.LoginAsync(request.Email, request.Password);

            if (!string.IsNullOrEmpty(result.Token))
                await SetRefreshCookie(result.UserUId);
            else if (!result.requiresVerification && !result.requires2FA)
                return Unauthorized(result);

            return Ok(result);
        }
        //  AllowAnonymous cho Google login
        [AllowAnonymous]
        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.IdToken) &&
                    string.IsNullOrWhiteSpace(request.AccessToken))
                {
                    return BadRequest(new { message = "Thiếu thông tin đăng nhập Google." });
                }

                string email;
                string name;

                if (!string.IsNullOrWhiteSpace(request.IdToken))
                {
                    var clientId = _configuration["GoogleAuth:ClientId"];
                    var settings = new GoogleJsonWebSignature.ValidationSettings();

                    if (!string.IsNullOrWhiteSpace(clientId))
                    {
                        settings.Audience = new[] { clientId };
                    }

                    var payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, settings);
                    email = payload.Email;
                    name = payload.Name;
                }
                else
                {
                    var googleUser = await GetGoogleUserInfoAsync(request.AccessToken!);

                    if (googleUser == null || string.IsNullOrEmpty(googleUser.Email))
                        return BadRequest(new { message = "Không thể lấy thông tin người dùng Google." });

                    email = googleUser.Email;
                    name = googleUser.Name;
                }

                var result = await _authService.GoogleLoginAsync(email, name);

                if (!string.IsNullOrEmpty(result.Token))
                    await SetRefreshCookie(result.UserUId);

                return Ok(result);
            }
            catch (InvalidJwtException)
            {
                return BadRequest(new { message = "Google idToken không hợp lệ." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Google login failed");
                return BadRequest(new { message = "Không thể đăng nhập bằng Google." });
            }
        }

        private static async Task<GoogleUserInfo?> GetGoogleUserInfoAsync(string accessToken)
        {
            using var httpClient = new HttpClient();
            using var googleResponse = await httpClient.GetAsync(
                $"https://www.googleapis.com/oauth2/v2/userinfo?access_token={Uri.EscapeDataString(accessToken)}");

            if (!googleResponse.IsSuccessStatusCode)
                return null;

            var json = await googleResponse.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<GoogleUserInfo>(json);
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
                return Unauthorized(new { message = "KhÃ´ng cÃ³ refresh token." });
            }

            try
            {
                var accessToken = await _authService.RefreshAccessTokenAsync(refreshToken);

                if (accessToken == null)
                {
                    _logger.LogWarning(" Refresh token invalid or expired");
                    return Unauthorized(new { message = "Refresh token khÃ´ng há»£p lá»‡ hoáº·c Ä‘Ã£ háº¿t háº¡n." });
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

        // QUAN TRá»ŒNG: AllowAnonymous cho logout
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
                // Váº«n xÃ³a localStorage á»Ÿ frontend
                return Ok(new { message = "ÄÃ£ Ä‘Äƒng xuáº¥t (khÃ´ng cÃ³ refresh token)." });
            }

            try
            {
                await _userService.UpdateStatusAccount(userUId, "Logout");
                await _authService.LogoutAsync(refreshToken);
                Response.Cookies.Delete("refreshToken");

                _logger.LogInformation(" Logout successful");
                return Ok(new { message = "ÄÃ£ Ä‘Äƒng xuáº¥t thÃ nh cÃ´ng." });
            }
            catch (Exception ex)
            {
                _logger.LogError($" Logout error: {ex.Message}");
                return Ok(new { message = "ÄÃ£ Ä‘Äƒng xuáº¥t (cÃ³ lá»—i khi xÃ³a session)." });
            }
        }

        //  AllowAnonymous cho verify-otp
        [AllowAnonymous]
        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest req)
        {
            var result = await _authService.VerifyOtpAsync(req.Email, req.Otp);

            if (!string.IsNullOrEmpty(result.Token))
                await SetRefreshCookie(result.UserUId);

            return Ok(result);
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
                    SameSite = SameSiteMode.Lax,   // Lax cho mÃ´i trÆ°á»ng local
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
                return BadRequest(new { message = "Email khÃ´ng há»£p lá»‡" });

            try
            {
                var success = await _authService.SendTwoFactorOtpAsync(email);

                if (!success)
                    return NotFound(new { message = "KhÃ´ng tÃ¬m tháº¥y tÃ i khoáº£n" });

                return Ok(new { message = "MÃ£ OTP Ä‘Ã£ Ä‘Æ°á»£c gá»­i vá» email" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Send 2FA OTP error: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
        }

        //  Verify OTP khi Báº¬T 2FA láº§n Ä‘áº§u (setup)
        [AllowAnonymous]
        [HttpPost("verify-2fa-setup")]
        public async Task<IActionResult> Verify2FASetup([FromQuery] string email, [FromQuery] string otp)
        {
            _logger.LogInformation($"[DEBUG] verify-2fa-setup called - Email: {email}, OTP: {otp}");

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(otp))
            {
                return BadRequest(new { message = "Thiáº¿u thÃ´ng tin xÃ¡c thá»±c" });
            }

            try
            {
                var result = await _authService.VerifyTwoFactorSetupAsync(email, otp);

                if (!result.IsTwoFactorEnabled)
                {
                    return BadRequest(new { message = result.Message });
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

        // â”€â”€â”€â”€â”€â”€â”€â”€â”€ 2FA TOTP Endpoints â”€â”€â”€â”€â”€â”€â”€â”€â”€

        /// <summary>
        /// BÆ°á»›c 2: Sinh SecretKey + QR URI cho Google Authenticator.
        /// </summary>
        [HttpGet("2fa/setup")]
        public async Task<IActionResult> Setup2FA([FromQuery] string userUId)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId khÃ´ng há»£p lá»‡" });

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
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[2FA Setup Error] {ex.Message}");
                return StatusCode(500, new { message = "ÄÃ£ xáº£y ra lá»—i khi thiáº¿t láº­p 2FA." });
            }
        }

        /// <summary>
        /// BÆ°á»›c 5: XÃ¡c thá»±c mÃ£ TOTP 6 sá»‘ vÃ  kÃ­ch hoáº¡t 2FA.
        /// </summary>
        [HttpPost("2fa/enable")]
        public async Task<IActionResult> Enable2FA([FromQuery] string userUId, [FromBody] Enable2FARequest request)
        {
            if (string.IsNullOrEmpty(userUId))
                return BadRequest(new { message = "userUId khÃ´ng há»£p lá»‡" });

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
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"[2FA Enable Error] {ex.Message}");
                return StatusCode(500, new { message = "ÄÃ£ xáº£y ra lá»—i khi kÃ­ch hoáº¡t 2FA." });
            }
        }

        [AllowAnonymous]
        [HttpGet("check-otp-status")]
        public async Task<IActionResult> CheckOtpStatus([FromQuery] string email)
        {
            if (string.IsNullOrEmpty(email))
                return BadRequest(new { message = "Email khÃ´ng há»£p lá»‡" });

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
    }
}
