using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class WorkflowNodeConfiguration : IEntityTypeConfiguration<WorkflowNode>
    {
        public void Configure(EntityTypeBuilder<WorkflowNode> builder)
        {
            builder.ToTable("WorkflowNodes");

            builder.HasKey(x => x.WorkflowNodeUId);

            builder.Property(x => x.WorkflowNodeUId)
                   .HasMaxLength(128);

            builder.Property(x => x.NodeType)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Board");

            builder.Property(x => x.ReferenceId)
                   .HasMaxLength(128);

            builder.Property(x => x.WorkflowDesignUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // WorkflowDesign → WorkflowNode: CASCADE
            builder.HasOne(x => x.WorkflowDesign)
                   .WithMany(d => d.Nodes)
                   .HasForeignKey(x => x.WorkflowDesignUId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => x.WorkflowDesignUId);
            builder.HasIndex(x => x.ReferenceId);
        }
    }
}
