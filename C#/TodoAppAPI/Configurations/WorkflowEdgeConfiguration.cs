using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class WorkflowEdgeConfiguration : IEntityTypeConfiguration<WorkflowEdge>
    {
        public void Configure(EntityTypeBuilder<WorkflowEdge> builder)
        {
            builder.ToTable("WorkflowEdges");

            builder.HasKey(x => x.WorkflowEdgeUId);

            builder.Property(x => x.WorkflowEdgeUId)
                   .HasMaxLength(128);

            builder.Property(x => x.EdgeType)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("dependency");

            builder.Property(x => x.Label)
                   .HasMaxLength(100);

            builder.Property(x => x.IsReversed)
                   .HasDefaultValue(false);

            builder.Property(x => x.WorkflowDesignUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.SourceNodeUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.TargetNodeUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // WorkflowDesign → WorkflowEdge: CASCADE
            builder.HasOne(x => x.WorkflowDesign)
                   .WithMany(d => d.Edges)
                   .HasForeignKey(x => x.WorkflowDesignUId)
                   .OnDelete(DeleteBehavior.Cascade);

            // SourceNode → WorkflowEdge: NoAction (avoid multiple cascade paths)
            builder.HasOne(x => x.SourceNode)
                   .WithMany(n => n.SourceEdges)
                   .HasForeignKey(x => x.SourceNodeUId)
                   .OnDelete(DeleteBehavior.NoAction);

            // TargetNode → WorkflowEdge: NoAction
            builder.HasOne(x => x.TargetNode)
                   .WithMany(n => n.TargetEdges)
                   .HasForeignKey(x => x.TargetNodeUId)
                   .OnDelete(DeleteBehavior.NoAction);

            builder.HasIndex(x => x.WorkflowDesignUId);
            builder.HasIndex(x => new { x.SourceNodeUId, x.TargetNodeUId }).IsUnique();
        }
    }
}
