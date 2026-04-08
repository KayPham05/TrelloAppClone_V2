using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class FileUrlConfiguration : IEntityTypeConfiguration<FileUrl>
    {
        public void Configure(EntityTypeBuilder<FileUrl> builder)
        {
            builder.ToTable("FileUrls");

            builder.HasKey(x => x.FileUId);
            builder.Property(x => x.FileUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Url)
                   .IsRequired();

            builder.Property(x => x.FileName)
                   .IsRequired()
                   .HasMaxLength(255);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Card → FileUrl: CASCADE
            builder.HasOne(x => x.Card)
                   .WithMany(c => c.FileUrls)
                   .HasForeignKey(x => x.CardUId)
                   .OnDelete(DeleteBehavior.Cascade); // Xóa card → xóa các files đính kèm
        }
    }
}
