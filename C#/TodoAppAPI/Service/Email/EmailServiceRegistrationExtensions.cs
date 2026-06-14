using Microsoft.Extensions.DependencyInjection;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Service
{
    public static class EmailServiceRegistrationExtensions
    {
        public static IServiceCollection AddEmailServices(this IServiceCollection services)
        {
            services.AddScoped<EmailService>();
            services.AddScoped<IEmailService>(provider => provider.GetRequiredService<EmailService>());

            return services;
        }
    }
}
