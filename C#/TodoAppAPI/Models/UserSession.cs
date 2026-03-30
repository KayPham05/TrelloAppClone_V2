using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace TodoAppAPI.Models
{
    public class UserSession
    {
        [Key]
        [ForeignKey("User")]
        [MaxLength(128)]
        public string UserUId { get; set; } = string.Empty;

        [Required]
        [MaxLength(512)]
        public string RefreshToken { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Device { get; set; }

        [MaxLength(45)]
        public string? IpAddress { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime ExpiresAt { get; set; }

        public bool IsRevoked { get; set; } = false;

        // Navigation
        public User? User { get; set; }
    }
}
