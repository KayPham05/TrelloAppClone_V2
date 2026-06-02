using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class WorkflowDesignConfiguration : IEntityTypeConfiguration<WorkflowDesign>
    {
        public void Configure(EntityTypeBuilder<WorkflowDesign> builder)
        {
            builder.ToTable("WorkflowDesigns");

            builder.HasKey(x => x.WorkflowDesignUId);

            builder.Property(x => x.WorkflowDesignUId)
                   .HasMaxLength(128);

            builder.Property(x => x.Name)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(x => x.Description)
                   .HasMaxLength(1000);

            builder.Property(x => x.WorkspaceUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.CreatedByUserUId)
                   .HasMaxLength(128);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.UpdatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Workspace → WorkflowDesign: CASCADE
            builder.HasOne(x => x.Workspace)
                   .WithMany()
                   .HasForeignKey(x => x.WorkspaceUId)
                   .OnDelete(DeleteBehavior.Cascade);

            // User → WorkflowDesign: SetNull
            builder.HasOne(x => x.CreatedBy)
                   .WithMany()
                   .HasForeignKey(x => x.CreatedByUserUId)
                   .OnDelete(DeleteBehavior.SetNull);

            builder.HasIndex(x => x.WorkspaceUId);
        }
    }
}
