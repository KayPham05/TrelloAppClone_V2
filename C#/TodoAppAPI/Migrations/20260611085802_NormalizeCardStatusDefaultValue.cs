using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class NormalizeCardStatusDefaultValue : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "Cards",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "to_do",
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50,
                oldDefaultValue: "To Do");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "Cards",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "To Do",
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50,
                oldDefaultValue: "to_do");
        }
    }
}
