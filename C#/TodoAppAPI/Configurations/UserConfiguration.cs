using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.ToTable("Users");

            builder.HasKey(x => x.UserUId);
            builder.Property(x => x.UserUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.UserName)
                   .IsRequired()
                   .HasMaxLength(100);

            builder.Property(x => x.Email)
                   .IsRequired()
                   .HasMaxLength(200);

            builder.Property(x => x.PasswordHash)
                   .IsRequired()
                   .HasMaxLength(200);
            builder.Property(x => x.IsEmailVerified)
                   .HasDefaultValue(false);

            builder.Property(x => x.VerificationTokenHash)
                   .HasMaxLength(256)
                   .IsRequired(false);

            builder.Property(u => u.VerificationTokenExpiresAt)
                   .IsRequired(false);

            builder.Property(x => x.Provider)
                   .IsRequired(false);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.Property(x => x.Bio)
                    .HasMaxLength(250);

            builder.Property(x => x.StatusAccount)
                    .HasMaxLength(100)
                    .IsRequired(true);

            builder.HasOne(x => x.Role)
                   .WithMany(r => r.Users)
                   .HasForeignKey(x => x.RoleId)
                   .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(u => u.Session)
                   .WithOne(s => s.User)
                   .HasForeignKey<UserSession>(s => s.UserUId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(u => u.UserOtp)
                   .WithOne(o => o.User)
                   .HasForeignKey<UserOtp>(o => o.UserUId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => x.Email).IsUnique();
        }
    }

}
