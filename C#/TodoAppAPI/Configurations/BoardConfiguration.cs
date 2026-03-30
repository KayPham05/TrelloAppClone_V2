using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class BoardConfiguration : IEntityTypeConfiguration<Board>
    {
        public void Configure(EntityTypeBuilder<Board> builder)
        {
            builder.ToTable("Boards");

            builder.HasKey(x => x.BoardUId);
            builder.Property(x => x.BoardUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.BoardName)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.Status)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Active");

            builder.Property(x => x.Visibility)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Private");

            builder.Property(x => x.IsPersonal)
                   .HasDefaultValue(false);

            // User → Board: Restrict (không xóa board khi xóa user)
            builder.HasOne(x => x.User)
                   .WithMany(u => u.OwnedBoards)
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.Restrict); // ← Restrict

            // Workspace → Board: Restrict
            builder.HasOne(x => x.Workspace)
                   .WithMany(w => w.Boards)
                   .HasForeignKey(x => x.WorkspaceUId)
                   .OnDelete(DeleteBehavior.Restrict) // ← Restrict
                   .IsRequired(false);

            builder.HasIndex(x => new { x.UserUId, x.IsPersonal });
        }
    }
}
