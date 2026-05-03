using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Controllers
{
    [Route("v1/api/users")]
    [ApiController]
    public class UserController : ControllerBase
    {
        public readonly IUserService _userService;
        private readonly ILogger<UserController> _logger;

        public UserController(IUserService userService, ILogger<UserController> logger)
        {
            _userService = userService;
            _logger = logger;
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

        //// PUT api/<UserController>/5
        //[HttpPut("{id}")]
        //public void Put(int id, [FromBody] string value)
        //{
        //}

        //// DELETE api/<UserController>/5
        //[HttpDelete("{id}")]
        //public void Delete(int id)
        //{
        //}

        [HttpPost("verify-code")]
        public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeRequest req)
        {
            if (string.IsNullOrEmpty(req.Email) || string.IsNullOrEmpty(req.Code))
                return BadRequest("Thiếu thông tin xác thực.");

            //  Lấy user theo email
            var user = await _userService.GetUserByEmail(req.Email);
            if (user == null)
                return NotFound("Không tìm thấy tài khoản.");

            //  Nếu đã xác thực rồi thì báo luôn
            if (user.IsEmailVerified)
                return Ok("Tài khoản đã được xác thực trước đó.");

            //  Kiểm tra hết hạn mã
            if (user.VerificationTokenExpiresAt == null || user.VerificationTokenExpiresAt < DateTime.UtcNow)
                return BadRequest(" Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới.");

            //  Kiểm tra mã hợp lệ
            bool valid = BCrypt.Net.BCrypt.Verify(req.Code, user.VerificationTokenHash);
            if (!valid)
                return BadRequest(" Mã xác thực không hợp lệ.");

            //  Cập nhật trạng thái xác thực
            user.IsEmailVerified = true;
            user.VerificationTokenHash = null;
            user.VerificationTokenExpiresAt = null;
            user.StatusAccount = "Isverified";
            await _userService.UpdateAsync(user);

            return Ok(" Xác thực thành công! Bạn có thể đăng nhập ngay bây giờ.");
        }


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

    }
}
