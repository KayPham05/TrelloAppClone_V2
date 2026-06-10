using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class AnalysisReportConfiguration : IEntityTypeConfiguration<AnalysisReport>
    {
        public void Configure(EntityTypeBuilder<AnalysisReport> builder)
        {
            builder.ToTable("AnalysisReports");

            builder.HasKey(x => x.ReportUId);

            builder.Property(x => x.ReportUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.ScopeType).IsRequired().HasMaxLength(50);
            builder.Property(x => x.ScopeUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.GeneratedByUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.Title).IsRequired().HasMaxLength(200);
            builder.Property(x => x.ModelUsed).IsRequired().HasMaxLength(100);
            builder.Property(x => x.ReportData).IsRequired();

            builder.HasIndex(x => new { x.ScopeType, x.ScopeUId, x.GeneratedAt });

            builder.HasOne(x => x.GeneratedBy)
                .WithMany()
                .HasForeignKey(x => x.GeneratedByUId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
