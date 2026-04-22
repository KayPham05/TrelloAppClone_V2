using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TodoAppAPI.Models
{
    public class CardLabel
    {
        [Key]
        public string CardLabelUId { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string CardUId { get; set; } = string.Empty;
        
        [ForeignKey("CardUId")]
        public virtual Card Card { get; set; }

        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string ColorCode { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
