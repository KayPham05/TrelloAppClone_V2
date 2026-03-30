using System.ComponentModel.DataAnnotations;

namespace TodoAppAPI.Models
{
    public class CardMember
    {
        [Key]
        [MaxLength(128)]
        public string CardMemberUId { get; set; } = Guid.NewGuid().ToString();

        [Required]
        [MaxLength(128)]
        public string CardUId { get; set; }
        public virtual Card Card { get; set; }

        [Required]
        [MaxLength(128)]
        public string UserUId { get; set; }
        public virtual User User { get; set; }

        [MaxLength(50)]
        public string Role { get; set; } = "Assignee";

        public DateTime AssignedAt { get; set; } = DateTime.Now;

    }
}
