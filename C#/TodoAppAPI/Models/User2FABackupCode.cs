using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TodoAppAPI.Models
{
    public class User2FABackupCode
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(128)]
        public string UserUId { get; set; } = string.Empty;

        [Required]
        [MaxLength(256)]
        public string CodeHash { get; set; } = string.Empty;

        public bool IsUsed { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        [ForeignKey("UserUId")]
        public User? User { get; set; }
    }
}
