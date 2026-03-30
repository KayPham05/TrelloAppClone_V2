using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class WorkspaceMemberConfiguration : IEntityTypeConfiguration<WorkspaceMemberDto>
    {
        public void Configure(EntityTypeBuilder<WorkspaceMemberDto> builder)
        {
            builder.ToTable("WorkspaceMembers");

            builder.HasKey(x => x.WorkspaceMemberUId);
            builder.Property(x => x.WorkspaceMemberUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Role)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Member");

            builder.Property(x => x.JoinedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Workspace → WorkspaceMember: CASCADE
            builder.HasOne(x => x.Workspace)
                   .WithMany(w => w.Members)
                   .HasForeignKey(x => x.WorkspaceUId)
                   .OnDelete(DeleteBehavior.Cascade); // ← CASCADE: Xóa workspace → xóa members

            // User → WorkspaceMember: NoAction
            builder.HasOne(x => x.User)
                   .WithMany(u => u.WorkspaceMemberships)
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.NoAction); // ← NoAction: Tránh conflict

            builder.HasIndex(x => new { x.WorkspaceUId, x.UserUId }).IsUnique();
        }
    }
}
