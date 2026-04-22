using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class User2FABackupCodeConfiguration : IEntityTypeConfiguration<User2FABackupCode>
    {
        public void Configure(EntityTypeBuilder<User2FABackupCode> builder)
        {
            builder.ToTable("User2FABackupCodes");

            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id)
                   .ValueGeneratedOnAdd();

            builder.Property(x => x.UserUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.CodeHash)
                   .IsRequired()
                   .HasMaxLength(256);

            builder.Property(x => x.IsUsed)
                   .HasDefaultValue(false);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.HasOne(x => x.User)
                   .WithMany(u => u.BackupCodes)
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
