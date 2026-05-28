using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using TodoAppAPI.Data;

namespace TodoAppAPI.Middlewares
{
    public class AccountLockMiddleware
    {
        private readonly RequestDelegate _next;

        public AccountLockMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, TodoDbContext dbContext)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var userId = context.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                if (!string.IsNullOrEmpty(userId))
                {
                    // Check if account is locked
                    var user = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(u => u.UserUId == userId);
                    if (user != null && user.StatusAccount == "Locked")
                    {
                        context.Response.StatusCode = 403;
                        context.Response.ContentType = "application/json";
                        var result = JsonSerializer.Serialize(new { message = "ACCOUNT_LOCKED", email = user.Email });
                        await context.Response.WriteAsync(result);
                        return;
                    }
                }
            }

            await _next(context);
        }
    }
}
