using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class UserRecentBoardConfiguaration: IEntityTypeConfiguration<UserRecentBoard>
    {

        public void Configure(EntityTypeBuilder<UserRecentBoard> builder)
        {
            builder.ToTable("UserRecentBoard");

            builder.HasKey(x => x.UserRecentBoardUId);
            builder.Property(x => x.UserRecentBoardUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.UserUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.BoardUId).IsRequired().HasMaxLength(128);
            builder.Property(x => x.LastVisitedAt).IsRequired();

            builder.HasOne(x => x.User)
                   .WithMany()
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.Cascade);


            builder.HasOne(x => x.Board)
                   .WithMany() 
                   .HasForeignKey(x => x.BoardUId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => x.UserUId);
            builder.HasIndex(x => x.LastVisitedAt);

        }
    }
}
