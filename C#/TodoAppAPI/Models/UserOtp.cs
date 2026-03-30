using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace TodoAppAPI.Models
{
    public class UserOtp
    {
        [Key]
        [ForeignKey("User")]
        [MaxLength(128)]
        public string UserUId { get; set; } = string.Empty;

        [Required, MaxLength(6)]
        public string OtpCode { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        // Navigation
        public User? User { get; set; }
    }
}
