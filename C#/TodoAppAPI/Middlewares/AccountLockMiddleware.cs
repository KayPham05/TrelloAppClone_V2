using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using TodoAppAPI.Data;

namespace TodoAppAPI.Middlewares
{
    public class CachedUserStatus
    {
        public string StatusAccount { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }

    public class AccountLockMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IMemoryCache _cache;

        public AccountLockMiddleware(RequestDelegate next, IMemoryCache cache)
        {
            _next = next;
            _cache = cache;
        }

        public async Task InvokeAsync(HttpContext context, TodoDbContext dbContext)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var userId = context.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                if (!string.IsNullOrEmpty(userId))
                {
                    var cacheKey = $"AccountLock_{userId}";

                    if (!_cache.TryGetValue(cacheKey, out CachedUserStatus? userStatus))
                    {
                        // Project only the needed columns, don't load the whole entity
                        userStatus = await dbContext.Users
                            .AsNoTracking()
                            .Where(u => u.UserUId == userId)
                            .Select(u => new CachedUserStatus { StatusAccount = u.StatusAccount, Email = u.Email })
                            .FirstOrDefaultAsync(context.RequestAborted);

                        if (userStatus != null)
                        {
                            // Cache the status for 1 minute to reduce DB load
                            _cache.Set(cacheKey, userStatus, TimeSpan.FromMinutes(1));
                        }
                    }

                    if (userStatus != null && userStatus.StatusAccount == "Locked")
                    {
                        context.Response.StatusCode = 403;
                        context.Response.ContentType = "application/json";
                        var result = JsonSerializer.Serialize(new { message = "ACCOUNT_LOCKED", email = userStatus.Email });
                        await context.Response.WriteAsync(result);
                        return;
                    }
                }
            }

            await _next(context);
        }
    }
}
