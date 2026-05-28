using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddCardDueDateReminderDeliveries : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CardDueDateReminderDeliveries",
                columns: table => new
                {
                    ReminderDeliveryId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    CardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Milestone = table.Column<int>(type: "int", nullable: false),
                    DueDateSnapshot = table.Column<DateTime>(type: "datetime2", nullable: false),
                    SentAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CardDueDateReminderDeliveries", x => x.ReminderDeliveryId);
                    table.ForeignKey(
                        name: "FK_CardDueDateReminderDeliveries_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CardDueDateReminderDeliveries_CardUId_Milestone",
                table: "CardDueDateReminderDeliveries",
                columns: new[] { "CardUId", "Milestone" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CardDueDateReminderDeliveries");
        }
    }
}
