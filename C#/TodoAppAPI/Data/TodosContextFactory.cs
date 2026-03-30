using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace TodoAppAPI.Data
{
    public class TodosContextFactory : IDesignTimeDbContextFactory<TodoDbContext>
    {
        public TodoDbContext CreateDbContext(string[] args)
        {
            IConfigurationRoot configurationRoot = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
            .Build();

            var connectionStrings = configurationRoot.GetConnectionString("TodosDatabase");

            var optionBuilder = new DbContextOptionsBuilder<TodoDbContext>();

            optionBuilder.UseSqlServer(connectionStrings);

            return new TodoDbContext(optionBuilder.Options);
        }
    }
}
