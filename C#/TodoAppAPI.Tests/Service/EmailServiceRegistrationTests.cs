using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Service;
using Xunit;

namespace TodoAppAPI.Tests.Service
{
    public class EmailServiceRegistrationTests
    {
        [Fact]
        public void AddEmailServices_ResolvesConcreteAndInterfaceToSameScopedInstance()
        {
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["EmailSettings:SenderEmail"] = "test@example.com",
                    ["EmailSettings:SenderPassword"] = "password",
                    ["EmailSettings:SmtpServer"] = "smtp.example.com",
                    ["EmailSettings:Port"] = "587"
                })
                .Build();

            var services = new ServiceCollection();
            services.AddSingleton<IConfiguration>(configuration);
            services.AddEmailServices();

            using var provider = services.BuildServiceProvider();
            using var scope = provider.CreateScope();

            var concrete = scope.ServiceProvider.GetRequiredService<EmailService>();
            var abstraction = scope.ServiceProvider.GetRequiredService<IEmailService>();

            Assert.Same(concrete, abstraction);
        }
    }
}
