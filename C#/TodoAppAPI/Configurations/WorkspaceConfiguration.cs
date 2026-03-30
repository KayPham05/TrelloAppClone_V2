using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class WorkspaceConfiguration : IEntityTypeConfiguration<Workspace>
    {
        public void Configure(EntityTypeBuilder<Workspace> builder)
        {
            builder.ToTable("Workspaces");

            builder.HasKey(x => x.WorkspaceUId);
            builder.Property(x => x.WorkspaceUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Name)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(x => x.Description)
                   .HasMaxLength(1000);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.Status)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Active");

            // User → Workspace: Restrict (không xóa workspace khi xóa user)
            builder.HasOne(x => x.Owner)
                   .WithMany(u => u.OwnedWorkspaces)
                   .HasForeignKey(x => x.OwnerUId)
                   .OnDelete(DeleteBehavior.Restrict); // ← Restrict
        }
    }
}
