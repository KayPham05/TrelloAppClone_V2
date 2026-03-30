using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Models;

namespace TodoAppAPI.Data
{
    public static class DatabaseSeeder
    {
        // ===== STATIC VALUES - KHÔNG THAY ĐỔI =====
        private static readonly DateTime SeedDate = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        private static readonly string User1Id = "550e8400-e29b-41d4-a716-446655440001";
        private static readonly string User2Id = "550e8400-e29b-41d4-a716-446655440002";

        private static readonly string Board1Id = "660e8400-e29b-41d4-a716-446655440001";
        private static readonly string Board2Id = "660e8400-e29b-41d4-a716-446655440002";

        private static readonly string List1Id = "770e8400-e29b-41d4-a716-446655440001";
        private static readonly string List2Id = "770e8400-e29b-41d4-a716-446655440002";
        private static readonly string List3Id = "770e8400-e29b-41d4-a716-446655440003";
        private static readonly string List4Id = "770e8400-e29b-41d4-a716-446655440004";

        private static readonly string WorkspaceId = "880e8400-e29b-41d4-a716-446655440001";
        private static readonly string WorkspaceMember1Id = "990e8400-e29b-41d4-a716-446655440001";
        private static readonly string WorkspaceMember2Id = "990e8400-e29b-41d4-a716-446655440002";

        public static void SeedData(ModelBuilder modelBuilder)
        {
            // 1. Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role
                {
                    RoleId = 1,
                    RoleName = "Admin",
                    Description = "System Administrator"
                },
                new Role
                {
                    RoleId = 2,
                    RoleName = "User",
                    Description = "Regular User"
                },
                new Role
                {
                    RoleId = 3,
                    RoleName = "Guest",
                    Description = "Guest User"
                }
            ); 
        }

            //// 2. Seed Sample Users
            //modelBuilder.Entity<User>().HasData(
            //    new User
            //    {
            //        UserUId = User1Id,
            //        UserName = "John Doe",
            //        Email = "john@example.com",
            //        PasswordHash = "AQAAAAEAACcQAAAAEHashed_Password_123", // Sample hash
            //        RoleId = 2,
            //        CreatedAt = SeedDate
            //    },
            //    new User
            //    {
            //        UserUId = User2Id,
            //        UserName = "Jane Smith",
            //        Email = "jane@example.com",
            //        PasswordHash = "AQAAAAEAACcQAAAAEHashed_Password_456",
            //        RoleId = 2,
            //        CreatedAt = SeedDate
            //    }
            //);

            //// 3. Seed Personal Boards
            //modelBuilder.Entity<Board>().HasData(
            //    new Board
            //    {
            //        BoardUId = Board1Id,
            //        BoardName = "My Personal Tasks",
            //        UserUId = User1Id,
            //        IsPersonal = true,
            //        Visibility = "Private",
            //        WorkspaceUId = null,
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    },
            //    new Board
            //    {
            //        BoardUId = Board2Id,
            //        BoardName = "My Personal Tasks",
            //        UserUId = User2Id,
            //        IsPersonal = true,
            //        Visibility = "Private",
            //        WorkspaceUId = null,
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    }
            //);

            //// 4. Seed Lists cho Personal Board của User 1
            //modelBuilder.Entity<List>().HasData(
            //    new List
            //    {
            //        ListUId = List1Id,
            //        ListName = "Inbox",
            //        BoardUId = Board1Id,
            //        Position = 0,
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    },
            //    new List
            //    {
            //        ListUId = List2Id,
            //        ListName = "Today",
            //        BoardUId = Board1Id,
            //        Position = 1,
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    },
            //    new List
            //    {
            //        ListUId = List3Id,
            //        ListName = "This Week",
            //        BoardUId = Board1Id,
            //        Position = 2,
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    }
            //);

            //// 5. Seed Lists cho Personal Board của User 2
            //modelBuilder.Entity<List>().HasData(
            //    new List
            //    {
            //        ListUId = List4Id,
            //        ListName = "Inbox",
            //        BoardUId = Board2Id,
            //        Position = 0,
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    }
            //);

            //// 6. Seed Sample Workspace
            //modelBuilder.Entity<Workspace>().HasData(
            //    new Workspace
            //    {
            //        WorkspaceUId = WorkspaceId,
            //        Name = "Marketing Team",
            //        OwnerUId = User1Id, // ← Thêm dòng này
            //        Status = "Active",
            //        CreatedAt = SeedDate
            //    }
            //);

            //// 7. Seed Workspace Members
            //modelBuilder.Entity<WorkspaceMember>().HasData(
            //    new WorkspaceMember
            //    {
            //        WorkspaceMemberUId = WorkspaceMember1Id,
            //        WorkspaceUId = WorkspaceId,
            //        UserUId = User1Id,
            //        Role = "Owner",
            //        JoinedAt = SeedDate
            //    },
            //    new WorkspaceMember
            //    {
            //        WorkspaceMemberUId = WorkspaceMember2Id,
            //        WorkspaceUId = WorkspaceId,
            //        UserUId = User2Id,
            //        Role = "Member",
            //        JoinedAt = SeedDate
            //    }
            //);
        //}
    }
}