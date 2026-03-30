using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class CardConfiguration : IEntityTypeConfiguration<Card>
    {
        public void Configure(EntityTypeBuilder<Card> builder)
        {
            builder.ToTable("Cards");

            builder.HasKey(x => x.CardUId);
            builder.Property(x => x.CardUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Title)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(x => x.Description)
                   .HasMaxLength(1000);

            builder.Property(x => x.Position)
                   .IsRequired();

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.Status)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("To Do");

            // List → Card: CASCADE (nullable for inbox cards)
            builder.HasOne(x => x.List)
                   .WithMany(l => l.Cards)
                   .HasForeignKey(x => x.ListUId)
                   .OnDelete(DeleteBehavior.Cascade) // ← CASCADE: Xóa list → xóa cards
                   .IsRequired(false);
        }
    }
}
