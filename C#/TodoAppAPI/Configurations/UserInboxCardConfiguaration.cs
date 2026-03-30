using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class UserInboxCardConfiguration : IEntityTypeConfiguration<UserInboxCard>
    {
        public void Configure(EntityTypeBuilder<UserInboxCard> builder)
        {
            builder.ToTable("UserInboxCards");

            builder.HasKey(x => new { x.UserUId, x.CardUId });

            builder.Property(x => x.UserUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.CardUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.AddedAt)
                   .HasDefaultValueSql("GETDATE()");

            // User → UserInboxCard: NoAction
            builder.HasOne(x => x.User)
                   .WithMany(u => u.InboxCards)
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.NoAction); // ← NoAction: Tránh conflict

            // Card → UserInboxCard: CASCADE
            builder.HasOne(x => x.Card)
                   .WithMany(c => c.UserInboxCards)
                   .HasForeignKey(x => x.CardUId)
                   .OnDelete(DeleteBehavior.Cascade); // ← CASCADE: Xóa card → xóa inbox entries
        }
    }
}
