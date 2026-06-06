using Microsoft.AspNetCore.Authentication.JwtBearer;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
using TodoAppAPI.Service;
using TodoAppAPI.Service.JWT;
using TodoAppAPI.Service.Cloudinary;
using TodoAppAPI.Service.Gemini;
using TodoAppAPI.Services;
using TodoAppAPI.Hubs;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseUrls("http://0.0.0.0:8080");
// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddSignalR();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICommentService, CommentService>();
builder.Services.AddScoped<IBoardService, BoardService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IListService, ListService>();
builder.Services.AddScoped<ICardsService, CardsService>();
builder.Services.AddScoped<IUserInboxCard, UserInboxCardService>();
builder.Services.AddScoped<IWorkspaceService, WorkspaceService>();
builder.Services.AddScoped<IUserRecentBoardService, UserBoardRecentService>();
builder.Services.AddScoped<ITodoItemService, TodoItemService>();
builder.Services.AddScoped<IBoardMemberService, BoardMemberService>();
builder.Services.AddScoped<ICardMemberService, CardMemberService>();
builder.Services.AddScoped<ICardLabelService, CardLabelService>();
builder.Services.AddScoped<EmailService>();
builder.Services.AddScoped<IActivity, ActivityService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<ICardDueDateReminderService, CardDueDateReminderService>();
builder.Services.AddScoped<ITwoFactorService, TwoFactorService>();
builder.Services.AddScoped<ISearchService, SearchService>();
builder.Services.AddScoped<IPlannerService, PlannerService>();
builder.Services.AddScoped<IGeminiAnalysisService, GeminiAnalysisService>();
builder.Services.AddHttpClient<IGeminiClient, GeminiClient>((serviceProvider, client) =>
{
    var settings = serviceProvider.GetRequiredService<Microsoft.Extensions.Options.IOptions<GeminiSettings>>().Value;
    client.Timeout = TimeSpan.FromSeconds(Math.Max(1, settings.TimeoutSeconds));
});
builder.Services.AddHostedService<CardDueDateReminderHostedService>();
builder.Services.AddScoped<IPlannerService, PlannerService>();

// IMemoryCache for 2FA temp secrets
builder.Services.AddMemoryCache();
builder.Services.AddScoped<IAuthorizationService, AuthorizationService>();

// Cloudinary
builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("CloudinarySettings"));
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();

// Gemini project analysis
builder.Services.Configure<GeminiSettings>(builder.Configuration.GetSection("GeminiSettings"));

// 1. JWT Security Validation
var jwtKey = builder.Configuration["Jwt:Key"];
if (string.IsNullOrEmpty(jwtKey) || jwtKey == "REPLACE_WITH_YOUR_OWN_SECRET_MIN_32_CHARS" || jwtKey.Length < 32)
{
    throw new Exception("CRITICAL ERROR: Invalid JWT Key. Vui lòng cập nhật Jwt:Key trong appsettings.Development.json thành một mã bí mật từ 32 ký tự trở lên để chạy ứng dụng.");
}

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero
        };
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) &&
                    path.StartsWithSegments("/hubs/notifications"))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Nhập token của bạn vào đây (không cần gõ chữ Bearer)"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

builder.Services.AddDbContext<TodoDbContext>(option =>
{
    option.UseSqlServer(builder.Configuration.GetConnectionString("TodosDatabase"));
});

//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("AllowAll", policy =>
//    {
//        policy.AllowAnyOrigin()
//              .AllowAnyHeader()
//              .AllowAnyMethod();
//    });
//});
// ================== CORS ==================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllWeb", policy =>
    {
        policy.SetIsOriginAllowed(origin => true)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.WriteIndented = true; // cho đẹp hơn
    });
var app = builder.Build();

// Configure the HTTP request pipeline.
    app.UseSwagger();
    app.UseSwaggerUI();


// 3. Sử dụng CORS
app.UseCors("AllowAllWeb");


//app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.UseMiddleware<TodoAppAPI.Middlewares.AccountLockMiddleware>();

app.MapControllers();
app.MapHub<NotificationHub>("/hubs/notifications");
app.MapHub<BoardHub>("/hubs/board");

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var context = services.GetRequiredService<TodoDbContext>(); // Thay bằng tên DbContext của bạn
    context.Database.Migrate(); // Ép EF tự tạo DB và chạy Migration lên SQL Server
}

app.Run();
