using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class ActivityService : IActivity
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly int MaxActionLength = 500;

        // ✅ Inject IServiceScopeFactory thay vì TodoDbContext
        public ActivityService(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
        }

        public async Task<bool> AddActivity(string userUId, string action)
        {
            try
            {
                // ✅ Tạo scope mới với DbContext riêng
                using (var scope = _scopeFactory.CreateScope())
                {
                    var context = scope.ServiceProvider.GetRequiredService<TodoDbContext>();

                    if (string.IsNullOrWhiteSpace(action))
                    {
                        action = "(no action)";
                    }

                    if (action.Length > MaxActionLength)
                    {
                        action = action.Substring(0, MaxActionLength);
                    }

                    var activity = new Activity
                    {
                        UserUId = string.IsNullOrWhiteSpace(userUId) ? null : userUId,
                        Action = action,
                        CreatedAt = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time"))
                    };

                    context.Activities.Add(activity);
                    await context.SaveChangesAsync();

                    Console.WriteLine($"✅ Activity logged: {action}");
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Activity log failed: {ex.GetType().Name} - {ex.Message}");
                return false;
            }
        }

        public async Task<List<ActivityDto>> GetActivities(int limit = 10, int offset = 0)
        {
            // ✅ Tạo scope mới cho mỗi query
            using (var scope = _scopeFactory.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<TodoDbContext>();

                return await context.Activities
                    .Include(a => a.User)
                    .OrderByDescending(a => a.CreatedAt)
                    .Skip(offset)
                    .Take(limit)
                    .Select(a => new ActivityDto
                    {
                        ActivityUId = a.ActivityUId,
                        Action = a.Action,
                        CreatedAt = a.CreatedAt,
                        User = a.User == null ? null : new UserDto
                        {
                            UserUId = a.User.UserUId,
                            Name = a.User.UserName,
                            Email = a.User.Email
                        }
                    })
                    .ToListAsync();
            }
        }

        public async Task<int> GetTotalCount()
        {
            using (var scope = _scopeFactory.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<TodoDbContext>();
                return await context.Activities.CountAsync();
            }
        }

        public async Task<List<ActivityDto>> GetActivitiesByUserUId(string userUId, int limit = 50)
        {
            using (var scope = _scopeFactory.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<TodoDbContext>();

                return await context.Activities
                    .Include(a => a.User)
                    .Where(a => a.UserUId == userUId)
                    .OrderByDescending(a => a.CreatedAt)
                    .Take(limit)
                    .Select(a => new ActivityDto
                    {
                        ActivityUId = a.ActivityUId,
                        Action = a.Action,
                        CreatedAt = a.CreatedAt,
                        User = a.User == null ? null : new UserDto
                        {
                            UserUId = a.User.UserUId,
                            Name = a.User.UserName,
                            Email = a.User.Email
                        }
                    })
                    .ToListAsync();
            }
        }
    }
}