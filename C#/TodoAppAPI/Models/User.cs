using System.Diagnostics;

namespace TodoAppAPI.Models
{
    public class User
    {
        public string UserUId { get; set; } = Guid.NewGuid().ToString(); // ← Not nullable
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public bool IsEmailVerified { get; set; } = false;
        public string? VerificationTokenHash { get; set; }
        public DateTime? VerificationTokenExpiresAt { get; set; }
        public string? Provider { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string Bio { get; set; } = string.Empty;

        public string StatusAccount { get; set; } = string.Empty;
        public bool IsTwoFactorEnabled { get; set; } = false;
        // FK - Role
        public int? RoleId { get; set; }
        public Role? Role { get; set; }

        public UserSession? Session { get; set; } 
        public UserOtp? UserOtp { get; set; }

        // Navigation Properties
        public ICollection<Board>? OwnedBoards { get; set; } // ← Changed from UserOwnerBoards
        public ICollection<Workspace>? OwnedWorkspaces { get; set; } // ← Added
        public ICollection<Activity>? Activities { get; set; }
        public ICollection<Comment>? Comments { get; set; }
        public ICollection<BoardMember>? BoardMemberships { get; set; }
        public ICollection<WorkspaceMemberDto>? WorkspaceMemberships { get; set; }
        public ICollection<UserInboxCard>? InboxCards { get; set; } // ← Changed from UserInboxCards
        public ICollection<Notification> ReceivedNotifications { get; set; } = new List<Notification>();
        public ICollection<Notification> SentNotifications { get; set; } = new List<Notification>();
    }
}
