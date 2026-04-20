using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace TodoAppAPI.Migrations
{
    /// <inheritdoc />
    public partial class Init_DB : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    RoleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.RoleId);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    UserName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    IsEmailVerified = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    VerificationTokenHash = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    VerificationTokenExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Provider = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    Bio = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    StatusAccount = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsTwoFactorEnabled = table.Column<bool>(type: "bit", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserUId);
                    table.ForeignKey(
                        name: "FK_Users_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    NotiId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    RecipientId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    ActorId = table.Column<string>(type: "nvarchar(128)", nullable: true),
                    Type = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(140)", maxLength: 140, nullable: false),
                    Message = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Link = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    WorkspaceId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                    BoardId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                    ListId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                    CardId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    Read = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    ReadAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.NotiId);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_ActorId",
                        column: x => x.ActorId,
                        principalTable: "Users",
                        principalColumn: "UserUId");
                    table.ForeignKey(
                        name: "FK_Notifications_Users_RecipientId",
                        column: x => x.RecipientId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserOtps",
                columns: table => new
                {
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    OtpCode = table.Column<string>(type: "nvarchar(6)", maxLength: 6, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserOtps", x => x.UserUId);
                    table.ForeignKey(
                        name: "FK_UserOtps_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserSessions",
                columns: table => new
                {
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    RefreshToken = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: false),
                    Device = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IpAddress = table.Column<string>(type: "nvarchar(45)", maxLength: 45, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsRevoked = table.Column<bool>(type: "bit", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserSessions", x => x.UserUId);
                    table.ForeignKey(
                        name: "FK_UserSessions_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Workspaces",
                columns: table => new
                {
                    WorkspaceUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Active"),
                    OwnerUId = table.Column<string>(type: "nvarchar(128)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Workspaces", x => x.WorkspaceUId);
                    table.ForeignKey(
                        name: "FK_Workspaces_Users_OwnerUId",
                        column: x => x.OwnerUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Boards",
                columns: table => new
                {
                    BoardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    BoardName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    IsPersonal = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    Visibility = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Private"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Active"),
                    BackgroundUrl = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserUId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    WorkspaceUId = table.Column<string>(type: "nvarchar(128)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Boards", x => x.BoardUId);
                    table.ForeignKey(
                        name: "FK_Boards_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Boards_Workspaces_WorkspaceUId",
                        column: x => x.WorkspaceUId,
                        principalTable: "Workspaces",
                        principalColumn: "WorkspaceUId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "WorkspaceMembers",
                columns: table => new
                {
                    WorkspaceMemberUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    WorkspaceUId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    UserUId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    Role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Member"),
                    JoinedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkspaceMembers", x => x.WorkspaceMemberUId);
                    table.ForeignKey(
                        name: "FK_WorkspaceMembers_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId");
                    table.ForeignKey(
                        name: "FK_WorkspaceMembers_Workspaces_WorkspaceUId",
                        column: x => x.WorkspaceUId,
                        principalTable: "Workspaces",
                        principalColumn: "WorkspaceUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "BoardMembers",
                columns: table => new
                {
                    BoardMemberUId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    BoardUId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    UserUId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    BoardRole = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Viewer"),
                    InvitedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BoardMembers", x => x.BoardMemberUId);
                    table.ForeignKey(
                        name: "FK_BoardMembers_Boards_BoardUId",
                        column: x => x.BoardUId,
                        principalTable: "Boards",
                        principalColumn: "BoardUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BoardMembers_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId");
                });

            migrationBuilder.CreateTable(
                name: "Lists",
                columns: table => new
                {
                    ListUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    ListName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Position = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Active"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    BoardUId = table.Column<string>(type: "nvarchar(128)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Lists", x => x.ListUId);
                    table.ForeignKey(
                        name: "FK_Lists_Boards_BoardUId",
                        column: x => x.BoardUId,
                        principalTable: "Boards",
                        principalColumn: "BoardUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserRecentBoard",
                columns: table => new
                {
                    UserRecentBoardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    BoardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    LastVisitedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRecentBoard", x => x.UserRecentBoardUId);
                    table.ForeignKey(
                        name: "FK_UserRecentBoard_Boards_BoardUId",
                        column: x => x.BoardUId,
                        principalTable: "Boards",
                        principalColumn: "BoardUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRecentBoard_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Cards",
                columns: table => new
                {
                    CardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    DueDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Position = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "To Do"),
                    BackgroundUrl = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ListUId = table.Column<string>(type: "nvarchar(128)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cards", x => x.CardUId);
                    table.ForeignKey(
                        name: "FK_Cards_Lists_ListUId",
                        column: x => x.ListUId,
                        principalTable: "Lists",
                        principalColumn: "ListUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Activities",
                columns: table => new
                {
                    ActivityUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Action = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UserUId = table.Column<string>(type: "nvarchar(128)", nullable: true),
                    CardUId = table.Column<string>(type: "nvarchar(128)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Activities", x => x.ActivityUId);
                    table.ForeignKey(
                        name: "FK_Activities_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId");
                    table.ForeignKey(
                        name: "FK_Activities_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId");
                });

            migrationBuilder.CreateTable(
                name: "CardMembers",
                columns: table => new
                {
                    CardMemberUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    CardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "Assignee"),
                    AssignedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CardMembers", x => x.CardMemberUId);
                    table.ForeignKey(
                        name: "FK_CardMembers_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CardMembers_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Comments",
                columns: table => new
                {
                    CommentUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    CardUId = table.Column<string>(type: "nvarchar(128)", nullable: false),
                    UserUId = table.Column<string>(type: "nvarchar(128)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Comments", x => x.CommentUId);
                    table.ForeignKey(
                        name: "FK_Comments_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Comments_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "FileUrls",
                columns: table => new
                {
                    FileUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Url = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FileName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    CardUId = table.Column<string>(type: "nvarchar(128)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FileUrls", x => x.FileUId);
                    table.ForeignKey(
                        name: "FK_FileUrls_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TodoItems",
                columns: table => new
                {
                    TodoItemUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    IsCompleted = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    CardUId = table.Column<string>(type: "nvarchar(128)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TodoItems", x => x.TodoItemUId);
                    table.ForeignKey(
                        name: "FK_TodoItems_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserInboxCards",
                columns: table => new
                {
                    UserUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    CardUId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    AddedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserInboxCards", x => new { x.UserUId, x.CardUId });
                    table.ForeignKey(
                        name: "FK_UserInboxCards_Cards_CardUId",
                        column: x => x.CardUId,
                        principalTable: "Cards",
                        principalColumn: "CardUId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserInboxCards_Users_UserUId",
                        column: x => x.UserUId,
                        principalTable: "Users",
                        principalColumn: "UserUId");
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "RoleId", "Description", "RoleName" },
                values: new object[,]
                {
                    { 1, "System Administrator", "Admin" },
                    { 2, "Regular User", "User" },
                    { 3, "Guest User", "Guest" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Activities_CardUId",
                table: "Activities",
                column: "CardUId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_UserUId",
                table: "Activities",
                column: "UserUId");

            migrationBuilder.CreateIndex(
                name: "IX_BoardMembers_BoardUId_UserUId",
                table: "BoardMembers",
                columns: new[] { "BoardUId", "UserUId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_BoardMembers_UserUId",
                table: "BoardMembers",
                column: "UserUId");

            migrationBuilder.CreateIndex(
                name: "IX_Boards_UserUId_IsPersonal",
                table: "Boards",
                columns: new[] { "UserUId", "IsPersonal" });

            migrationBuilder.CreateIndex(
                name: "IX_Boards_WorkspaceUId",
                table: "Boards",
                column: "WorkspaceUId");

            migrationBuilder.CreateIndex(
                name: "IX_CardMembers_CardUId_UserUId",
                table: "CardMembers",
                columns: new[] { "CardUId", "UserUId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CardMembers_UserUId",
                table: "CardMembers",
                column: "UserUId");

            migrationBuilder.CreateIndex(
                name: "IX_Cards_ListUId",
                table: "Cards",
                column: "ListUId");

            migrationBuilder.CreateIndex(
                name: "IX_Comments_CardUId",
                table: "Comments",
                column: "CardUId");

            migrationBuilder.CreateIndex(
                name: "IX_Comments_UserUId",
                table: "Comments",
                column: "UserUId");

            migrationBuilder.CreateIndex(
                name: "IX_FileUrls_CardUId",
                table: "FileUrls",
                column: "CardUId");

            migrationBuilder.CreateIndex(
                name: "IX_Lists_BoardUId",
                table: "Lists",
                column: "BoardUId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_ActorId",
                table: "Notifications",
                column: "ActorId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_BoardId_CreatedAt",
                table: "Notifications",
                columns: new[] { "BoardId", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_CardId_CreatedAt",
                table: "Notifications",
                columns: new[] { "CardId", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_RecipientId_Read_CreatedAt",
                table: "Notifications",
                columns: new[] { "RecipientId", "Read", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_TodoItems_CardUId",
                table: "TodoItems",
                column: "CardUId");

            migrationBuilder.CreateIndex(
                name: "IX_UserInboxCards_CardUId",
                table: "UserInboxCards",
                column: "CardUId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRecentBoard_BoardUId",
                table: "UserRecentBoard",
                column: "BoardUId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRecentBoard_LastVisitedAt",
                table: "UserRecentBoard",
                column: "LastVisitedAt");

            migrationBuilder.CreateIndex(
                name: "IX_UserRecentBoard_UserUId",
                table: "UserRecentBoard",
                column: "UserUId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_RoleId",
                table: "Users",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkspaceMembers_UserUId",
                table: "WorkspaceMembers",
                column: "UserUId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkspaceMembers_WorkspaceUId_UserUId",
                table: "WorkspaceMembers",
                columns: new[] { "WorkspaceUId", "UserUId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Workspaces_OwnerUId",
                table: "Workspaces",
                column: "OwnerUId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Activities");

            migrationBuilder.DropTable(
                name: "BoardMembers");

            migrationBuilder.DropTable(
                name: "CardMembers");

            migrationBuilder.DropTable(
                name: "Comments");

            migrationBuilder.DropTable(
                name: "FileUrls");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "TodoItems");

            migrationBuilder.DropTable(
                name: "UserInboxCards");

            migrationBuilder.DropTable(
                name: "UserOtps");

            migrationBuilder.DropTable(
                name: "UserRecentBoard");

            migrationBuilder.DropTable(
                name: "UserSessions");

            migrationBuilder.DropTable(
                name: "WorkspaceMembers");

            migrationBuilder.DropTable(
                name: "Cards");

            migrationBuilder.DropTable(
                name: "Lists");

            migrationBuilder.DropTable(
                name: "Boards");

            migrationBuilder.DropTable(
                name: "Workspaces");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Roles");
        }
    }
}
