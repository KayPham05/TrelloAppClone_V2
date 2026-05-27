using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class Initnode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "WorkflowDesigns",
                columns: table => new
                {
                    WorkflowDesignUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    WorkspaceUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    CreatedByUserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkflowDesigns", x => x.WorkflowDesignUId);
                    table.ForeignKey(
                        name: "FK_WorkflowDesigns_Users_CreatedByUserUId",
                        column: x => x.CreatedByUserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_WorkflowDesigns_Workspaces_WorkspaceUId",
                        column: x => x.WorkspaceUId,
                        principalTable: "Workspaces",
                        principalColumn: "WorkspaceUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WorkflowNodes",
                columns: table => new
                {
                    WorkflowNodeUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    NodeType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Board"),
                    ReferenceId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                    PositionX = table.Column<double>(type: "float", nullable: false),
                    PositionY = table.Column<double>(type: "float", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    WorkflowDesignUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkflowNodes", x => x.WorkflowNodeUId);
                    table.ForeignKey(
                        name: "FK_WorkflowNodes_WorkflowDesigns_WorkflowDesignUId",
                        column: x => x.WorkflowDesignUId,
                        principalTable: "WorkflowDesigns",
                        principalColumn: "WorkflowDesignUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WorkflowEdges",
                columns: table => new
                {
                    WorkflowEdgeUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    EdgeType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "dependency"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    WorkflowDesignUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    SourceNodeUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    TargetNodeUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkflowEdges", x => x.WorkflowEdgeUId);
                    table.ForeignKey(
                        name: "FK_WorkflowEdges_WorkflowDesigns_WorkflowDesignUId",
                        column: x => x.WorkflowDesignUId,
                        principalTable: "WorkflowDesigns",
                        principalColumn: "WorkflowDesignUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_WorkflowEdges_WorkflowNodes_SourceNodeUId",
                        column: x => x.SourceNodeUId,
                        principalTable: "WorkflowNodes",
                        principalColumn: "WorkflowNodeUId");
                    table.ForeignKey(
                        name: "FK_WorkflowEdges_WorkflowNodes_TargetNodeUId",
                        column: x => x.TargetNodeUId,
                        principalTable: "WorkflowNodes",
                        principalColumn: "WorkflowNodeUId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowDesigns_CreatedByUserUId",
                table: "WorkflowDesigns",
                column: "CreatedByUserUId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowDesigns_WorkspaceUId",
                table: "WorkflowDesigns",
                column: "WorkspaceUId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowEdges_SourceNodeUId_TargetNodeUId",
                table: "WorkflowEdges",
                columns: new[] { "SourceNodeUId", "TargetNodeUId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowEdges_TargetNodeUId",
                table: "WorkflowEdges",
                column: "TargetNodeUId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowEdges_WorkflowDesignUId",
                table: "WorkflowEdges",
                column: "WorkflowDesignUId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowNodes_ReferenceId",
                table: "WorkflowNodes",
                column: "ReferenceId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkflowNodes_WorkflowDesignUId",
                table: "WorkflowNodes",
                column: "WorkflowDesignUId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "WorkflowEdges");

            migrationBuilder.DropTable(
                name: "WorkflowNodes");

            migrationBuilder.DropTable(
                name: "WorkflowDesigns");
        }
    }
}
