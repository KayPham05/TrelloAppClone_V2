using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class CommentConfiguration : IEntityTypeConfiguration<Comment>
    {
        public void Configure(EntityTypeBuilder<Comment> builder)
        {
            builder.ToTable("Comments");

            builder.HasKey(x => x.CommentUId);
            builder.Property(x => x.CommentUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Content)
                   .IsRequired()
                   .HasMaxLength(500);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Card → Comment: CASCADE
            builder.HasOne(x => x.Card)
                   .WithMany(c => c.Comments)
                   .HasForeignKey(x => x.CardUId)
                   .OnDelete(DeleteBehavior.Cascade); // ← CASCADE: Xóa card → xóa comments

            // User → Comment: SetNull
            builder.HasOne(x => x.User)
                   .WithMany(u => u.Comments)
                   .HasForeignKey(x => x.UserUId)
                   .OnDelete(DeleteBehavior.SetNull); // ← SetNull: Xóa user → comment.UserUId = null
        }
    }
}
