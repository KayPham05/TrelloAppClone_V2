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
        public UserController(IUserService userService)
        {
            _userService = userService;
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
            var user = await _userService.GetUserByEmail(email);
            if (user == null) return NotFound("Không tìm thấy tài khoản.");

            if (user.IsEmailVerified)
                return Ok(new { verified = true });

            if (user.VerificationTokenExpiresAt == null)
                return Ok(new { verified = false, remainingSeconds = 0 });

            var remaining = (int)(user.VerificationTokenExpiresAt.Value - DateTime.UtcNow).TotalSeconds;
            return Ok(new
            {
                verified = false,
                remainingSeconds = Math.Max(0, remaining)
            });
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

    }
}
