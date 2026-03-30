using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class CardMemberConfiguration : IEntityTypeConfiguration<CardMember>
    {
        public void Configure(EntityTypeBuilder<CardMember> builder)
        {
            builder.ToTable("CardMembers");

            builder.HasKey(cm => cm.CardMemberUId);

            builder.Property(cm => cm.CardMemberUId)
                   .HasMaxLength(128);

            builder.Property(cm => cm.CardUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(cm => cm.UserUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(cm => cm.Role)
                   .HasMaxLength(50)
                   .HasDefaultValue("Assignee");

            builder.Property(cm => cm.AssignedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Quan hệ với Card
            builder.HasOne(cm => cm.Card)
                   .WithMany(c => c.CardMembers)
                   .HasForeignKey(cm => cm.CardUId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Quan hệ với User
            builder.HasOne(cm => cm.User)
                   .WithMany()
                   .HasForeignKey(cm => cm.UserUId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Unique (CardUId + UserUId)
            builder.HasIndex(cm => new { cm.CardUId, cm.UserUId })
                   .IsUnique();
        }
    }
}
