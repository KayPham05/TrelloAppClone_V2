using System;
using System.ComponentModel.DataAnnotations;

namespace TodoAppAPI.Models
{
    public class PermissionAudit
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string ResourceId { get; set; } = string.Empty; // WorkspaceId, BoardId, etc.

        [Required]
        [MaxLength(20)]
        public string ResourceType { get; set; } = string.Empty; // "Workspace", "Board"

        [Required]
        [MaxLength(100)]
        public string TargetUserUId { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string ActionByUserUId { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string ActionType { get; set; } = string.Empty; // "ChangeRole", "AddMember", "RemoveMember"

        [MaxLength(50)]
        public string? OldRole { get; set; }

        [MaxLength(50)]
        public string? NewRole { get; set; }

        public DateTime ActionAt { get; set; } = DateTime.UtcNow;
    }
}
