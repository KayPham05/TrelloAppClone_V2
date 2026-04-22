using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class Add2FASupport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TwoFactorSecret",
                table: "Users",
                type: "nvarchar(256)",
                maxLength: 256,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "User2FABackupCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    CodeHash = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    IsUsed = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_User2FABackupCodes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_User2FABackupCodes_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_User2FABackupCodes_UserUId",
                table: "User2FABackupCodes",
                column: "UserUId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "User2FABackupCodes");

            migrationBuilder.DropColumn(
                name: "TwoFactorSecret",
                table: "Users");
        }
    }
}
