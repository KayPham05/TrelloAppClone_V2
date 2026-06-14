using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddCommentAttachmentSupport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Comments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "CommentAttachments",
                columns: table => new
                {
                    AttachmentUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Url = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FileName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    CommentUId = table.Column<string>(type: "nvarchar(128)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CommentAttachments", x => x.AttachmentUId);
                    table.ForeignKey(
                        name: "FK_CommentAttachments_Comments_CommentUId",
                        column: x => x.CommentUId,
                        principalTable: "Comments",
                        principalColumn: "CommentUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CommentAttachments_CommentUId",
                table: "CommentAttachments",
                column: "CommentUId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CommentAttachments");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Comments");
        }
    }
}
