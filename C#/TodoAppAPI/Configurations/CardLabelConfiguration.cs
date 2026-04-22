using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class CardLabelConfiguration : IEntityTypeConfiguration<CardLabel>
    {
        public void Configure(EntityTypeBuilder<CardLabel> builder)
        {
            builder.HasKey(cl => cl.CardLabelUId);

            builder.Property(cl => cl.Title)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(cl => cl.ColorCode)
                .IsRequired()
                .HasMaxLength(20);

            builder.HasOne(cl => cl.Card)
                .WithMany(c => c.CardLabels)
                .HasForeignKey(cl => cl.CardUId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
