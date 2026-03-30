using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TodoAppAPI.Models;

namespace TodoAppAPI.Configurations
{
    public class TodoItemConfiguration : IEntityTypeConfiguration<TodoItem>
    {
        public void Configure(EntityTypeBuilder<TodoItem> builder)
        {
            builder.ToTable("TodoItems");

            builder.HasKey(x => x.TodoItemUId);
            builder.Property(x => x.TodoItemUId)
                   .IsRequired()
                   .HasMaxLength(128);

            builder.Property(x => x.Content)
                   .IsRequired()
                   .HasMaxLength(300);

            builder.Property(x => x.CreatedAt)
                   .HasDefaultValueSql("GETDATE()");

            // Card → TodoItem: CASCADE
            builder.HasOne(x => x.Card)
                   .WithMany(c => c.TodoItems)
                   .HasForeignKey(x => x.CardUId)
                   .OnDelete(DeleteBehavior.Cascade); // ← CASCADE: Xóa card → xóa todo items
        }
    }
}
