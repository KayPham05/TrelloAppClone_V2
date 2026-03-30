using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class ActivityConfiguration : IEntityTypeConfiguration<Activity>
    {
        public void Configure(EntityTypeBuilder<Activity> builder)
        {
            builder.ToTable("Activities");

            builder.HasKey(x => x.ActivityUId);
            builder.Property(x => x.ActivityUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Action)
                   .IsRequired(false)
                   .HasMaxLength(200);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETUTCDATE()");

            // User → Activity: NoAction
            builder.HasOne(x => x.User)
                   .WithMany(u => u.Activities)
                   .HasForeignKey(x => x.UserUId)
                   .IsRequired(false)
                   .OnDelete(DeleteBehavior.NoAction);
        }
    }
}
