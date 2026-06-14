using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddUserStarredBoard : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "UserStarredBoard",
                columns: table => new
                {
                    UserStarredBoardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    BoardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    StarredAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserStarredBoard", x => x.UserStarredBoardUId);
                    table.ForeignKey(
                        name: "FK_UserStarredBoard_Boards_BoardUId",
                        column: x => x.BoardUId,
                        principalTable: "Boards",
                        principalColumn: "BoardUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserStarredBoard_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserStarredBoard_BoardUId",
                table: "UserStarredBoard",
                column: "BoardUId");

            migrationBuilder.CreateIndex(
                name: "IX_UserStarredBoard_StarredAt",
                table: "UserStarredBoard",
                column: "StarredAt");

            migrationBuilder.CreateIndex(
                name: "IX_UserStarredBoard_UserUId_BoardUId",
                table: "UserStarredBoard",
                columns: new[] { "UserUId", "BoardUId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserStarredBoard");
        }
    }
}
