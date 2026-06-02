using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddCardArchiveAndBoardJoinCard : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsArchived",
                table: "Cards",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "AllowMemberJoinCard",
                table: "Boards",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsArchived",
                table: "Cards");

            migrationBuilder.DropColumn(
                name: "AllowMemberJoinCard",
                table: "Boards");
        }
    }
}
