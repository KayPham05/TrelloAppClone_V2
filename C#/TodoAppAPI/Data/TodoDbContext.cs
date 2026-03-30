using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Configurations;
using TodoAppAPI.Models;


namespace TodoAppAPI.Data
{
    public class TodoDbContext : DbContext
    {
        public TodoDbContext(DbContextOptions<TodoDbContext> options) : base(options)
        { 
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseLazyLoadingProxies();
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfiguration(new UserConfiguration());
            modelBuilder.ApplyConfiguration(new BoardConfiguration());
            modelBuilder.ApplyConfiguration(new ListConfiguration());
            modelBuilder.ApplyConfiguration(new CardConfiguration());
            modelBuilder.ApplyConfiguration(new ActivityConfiguration());
            modelBuilder.ApplyConfiguration(new TodoItemConfiguration());
            modelBuilder.ApplyConfiguration(new CommentConfiguration());
            modelBuilder.ApplyConfiguration(new RoleConfiguration());
            modelBuilder.ApplyConfiguration(new BoardMemberConfiguration());
            modelBuilder.ApplyConfiguration(new UserInboxCardConfiguration());
            modelBuilder.ApplyConfiguration(new WorkspaceConfiguration());
            modelBuilder.ApplyConfiguration(new WorkspaceMemberConfiguration());
            modelBuilder.ApplyConfiguration(new UserRecentBoardConfiguaration());
            modelBuilder.ApplyConfiguration(new CardMemberConfiguration());
            modelBuilder.ApplyConfiguration(new UserSessionConfiguration());
            modelBuilder.ApplyConfiguration(new UserOtpConfiguration());
            modelBuilder.ApplyConfiguration(new NotificationConfiguration());
            DatabaseSeeder.SeedData(modelBuilder);
        }

        public DbSet<Card> Todos { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Board> Boards { get; set; }
        public DbSet<List> Lists { get; set; }
        public DbSet<Activity> Activities { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<BoardMember> BoardMembers { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<TodoItem> TodoItems { get; set; }
        public DbSet<UserInboxCard> UserInboxCards { get; set; }
        public DbSet<Workspace> Workspaces { get; set; }
        public DbSet<WorkspaceMemberDto> WorkspaceMembers { get; set; }
        public DbSet<UserRecentBoard> UserRecentBoards { get; set; }
        public DbSet<CardMember> CardMembers { get; set; }
        public DbSet<UserSession> UserSessions { get; set; }
        public DbSet<UserOtp> UserOtps { get; set; }
        public DbSet<Notification> Notifications { get; set; }
    }
}
