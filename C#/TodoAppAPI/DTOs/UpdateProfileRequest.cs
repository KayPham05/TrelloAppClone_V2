using Microsoft.AspNetCore.Http;

namespace TodoAppAPI.DTOs
{
    public class UpdateProfileRequest
    {
        public string? UserName { get; set; }
        public string? Bio { get; set; }
        public IFormFile? Avatar { get; set; }
    }
}
