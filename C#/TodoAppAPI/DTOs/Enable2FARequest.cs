using System.ComponentModel.DataAnnotations;

namespace TodoAppAPI.DTOs
{
    public class Enable2FARequest
    {
        [Required]
        [StringLength(6, MinimumLength = 6, ErrorMessage = "Code must be exactly 6 digits.")]
        [RegularExpression(@"^\d{6}$", ErrorMessage = "Code must contain only digits.")]
        public string Code { get; set; } = string.Empty;
    }
}
