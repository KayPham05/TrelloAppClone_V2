using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class ListConfiguration : IEntityTypeConfiguration<List>
    {
        public void Configure(EntityTypeBuilder<List> builder)
        {
            builder.ToTable("Lists");

            builder.HasKey(x => x.ListUId);
            builder.Property(x => x.ListUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.ListName)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(x => x.Position)
                   .IsRequired();

            builder.Property(x => x.Status)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Active");

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Board → List: CASCADE
            builder.HasOne(x => x.Board)
                   .WithMany(b => b.Lists)
                   .HasForeignKey(x => x.BoardUId)
                   .OnDelete(DeleteBehavior.Cascade); // ← CASCADE: Xóa board → xóa lists
        }
    }
}