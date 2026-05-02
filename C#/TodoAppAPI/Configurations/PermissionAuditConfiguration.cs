using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class PermissionAuditConfiguration : IEntityTypeConfiguration<PermissionAudit>
    {
        public void Configure(EntityTypeBuilder<PermissionAudit> builder)
        {
            builder.ToTable("PermissionAudits");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.ResourceId).IsRequired().HasMaxLength(100);
            builder.Property(x => x.ResourceType).IsRequired().HasMaxLength(20);
            builder.Property(x => x.TargetUserUId).IsRequired().HasMaxLength(100);
            builder.Property(x => x.ActionByUserUId).IsRequired().HasMaxLength(100);
            builder.Property(x => x.ActionType).IsRequired().HasMaxLength(50);
            builder.Property(x => x.OldRole).HasMaxLength(50);
            builder.Property(x => x.NewRole).HasMaxLength(50);
            builder.Property(x => x.ActionAt).IsRequired();
        }
    }
}
