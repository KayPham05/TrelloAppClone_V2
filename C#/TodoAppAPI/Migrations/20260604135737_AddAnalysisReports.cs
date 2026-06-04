using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddAnalysisReports : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AnalysisReports",
                columns: table => new
                {
                    ReportUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    ScopeType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ScopeUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    GeneratedByUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    GeneratedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    OverallProgress = table.Column<int>(type: "int", nullable: false),
                    ModelUsed = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ReportData = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AnalysisReports", x => x.ReportUId);
                    table.ForeignKey(
                        name: "FK_AnalysisReports_Users_GeneratedByUId",
                        column: x => x.GeneratedByUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AnalysisReports_GeneratedByUId",
                table: "AnalysisReports",
                column: "GeneratedByUId");

            migrationBuilder.CreateIndex(
                name: "IX_AnalysisReports_ScopeType_ScopeUId_GeneratedAt",
                table: "AnalysisReports",
                columns: new[] { "ScopeType", "ScopeUId", "GeneratedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AnalysisReports");
        }
    }
}
