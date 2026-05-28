using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class CardDueDateReminderDeliveryConfiguration : IEntityTypeConfiguration<CardDueDateReminderDelivery>
    {
        public void Configure(EntityTypeBuilder<CardDueDateReminderDelivery> builder)
        {
            builder.ToTable("CardDueDateReminderDeliveries");

            builder.HasKey(x => x.ReminderDeliveryId);
            builder.Property(x => x.ReminderDeliveryId)
                .IsRequired()
                .HasMaxLength(128);

            builder.Property(x => x.CardUId)
                .IsRequired()
                .HasMaxLength(128);

            builder.Property(x => x.Milestone).IsRequired();
            builder.Property(x => x.DueDateSnapshot).IsRequired();
            builder.Property(x => x.SentAt).IsRequired();

            builder.HasIndex(x => new { x.CardUId, x.Milestone }).IsUnique();

            builder.HasOne(x => x.Card)
                .WithMany()
                .HasForeignKey(x => x.CardUId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        }
    }
}
