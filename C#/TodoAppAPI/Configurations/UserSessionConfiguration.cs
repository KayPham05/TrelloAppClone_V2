using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class UserSessionConfiguration : IEntityTypeConfiguration<UserSession>
    {
        public void Configure(EntityTypeBuilder<UserSession> builder)
        {
            builder.ToTable("UserSessions");

            builder.HasKey(x => x.UserUId);
            builder.Property(x => x.RefreshToken).IsRequired().HasMaxLength(512);
            builder.Property(x => x.Device).HasMaxLength(100);
            builder.Property(x => x.IpAddress).HasMaxLength(45);
            builder.Property(x => x.IsRevoked).HasDefaultValue(false);
        }
    }
}
