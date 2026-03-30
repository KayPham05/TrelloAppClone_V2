using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class UserOtpConfiguration : IEntityTypeConfiguration<UserOtp>
    {
        public void Configure(EntityTypeBuilder<UserOtp> builder)
        {
            builder.ToTable("UserOtps");

            builder.HasKey(x => x.UserUId);
            builder.Property(x => x.OtpCode).IsRequired().HasMaxLength(6);
            builder.Property(x => x.ExpiresAt).IsRequired();
        }
    }
}
