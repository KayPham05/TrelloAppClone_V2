using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class UserStarredBoardConfiguration : IEntityTypeConfiguration<UserStarredBoard>
    {
        public void Configure(EntityTypeBuilder<UserStarredBoard> builder)
        {
            builder.ToTable("UserStarredBoard");

            builder.HasKey(x => x.UserStarredBoardUId);
            builder.Property(x => x.UserStarredBoardUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.UserUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.BoardUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.StarredAt).IsRequired();

            builder.HasOne(x => x.User)
                   .WithMany()
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(x => x.Board)
                   .WithMany()
                   .HasForeignKey(x => x.BoardUId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => new { x.UserUId, x.BoardUId }).IsUnique();
            builder.HasIndex(x => x.StarredAt);
        }
    }
}
