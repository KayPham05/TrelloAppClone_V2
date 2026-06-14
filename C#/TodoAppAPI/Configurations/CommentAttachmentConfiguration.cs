using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class CommentAttachmentConfiguration : IEntityTypeConfiguration<CommentAttachment>
    {
        public void Configure(EntityTypeBuilder<CommentAttachment> builder)
        {
            builder.ToTable("CommentAttachments");

            builder.HasKey(x => x.AttachmentUId);
            builder.Property(x => x.AttachmentUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Url)
                   .IsRequired();

            builder.Property(x => x.FileName)
                   .IsRequired()
                   .HasMaxLength(255);

            builder.Property(x => x.Description)
                   .HasMaxLength(500);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            builder.HasOne(x => x.Comment)
                   .WithMany(c => c.Attachments)
                   .HasForeignKey(x => x.CommentUId)
                   .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
