using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class BoardMemberConfiguration : IEntityTypeConfiguration<BoardMember>
    {
        public void Configure(EntityTypeBuilder<BoardMember> builder)
        {
            builder.ToTable("BoardMembers");

            builder.HasKey(x => x.BoardMemberUId);

            builder.Property(x => x.BoardRole)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Viewer");

            builder.Property(x => x.InvitedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Board → BoardMember: CASCADE
            builder.HasOne(x => x.Board)
                   .WithMany(b => b.Members)
                   .HasForeignKey(x => x.BoardUId)
                   .OnDelete(DeleteBehavior.Cascade); // ← CASCADE: Xóa board → xóa members

            // User → BoardMember: NoAction
            builder.HasOne(x => x.User)
                   .WithMany(u => u.BoardMemberships)
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.NoAction); // ← NoAction: Tránh conflict

            builder.HasIndex(x => new { x.BoardUId, x.UserUId }).IsUnique();
        }
    }
}
