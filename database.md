# Database Schema Documentation

This document describes the database structure for the TrelloAppClone_V2 backend (TodoAppAPI).

## Overview
The database is built using Entity Framework Core and SQL Server. It follows a multi-tenant workspace architecture with Role-Based Access Control (RBAC).

---

## 1. Identity & Access Management

### `Roles`
Defines system-level roles for users.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| RoleId | int | No | PK, Identity | Unique identifier for the role. |
| RoleName | nvarchar(50) | No | | Name (e.g., Admin, User, Guest). |
| Description | nvarchar(200)| Yes | | Optional description. |

### `Users`
Stores user account information.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| UserUId | nvarchar(128) | No | PK | Unique identifier (UID). |
| UserName | nvarchar(100) | No | | Display name. |
| Email | nvarchar(200) | No | Unique Index | User email. |
| PasswordHash | nvarchar(200) | No | | Hashed password. |
| IsEmailVerified | bit | No | Default: 0 | Verification status. |
| VerificationTokenHash | nvarchar(256) | Yes | | Token for email verification. |
| VerificationTokenExpiresAt | datetime2 | Yes | | Expiry for verification token. |
| Provider | nvarchar(max) | Yes | | Auth provider (local/google). |
| CreatedAt | datetime2 | No | Default: GETDATE() | Account creation date. |
| Bio | nvarchar(250) | No | | User profile bio. |
| AvatarUrl | nvarchar(max) | Yes | | Link to avatar image. |
| StatusAccount | nvarchar(100) | No | | Account status (Active/Suspended).|
| IsTwoFactorEnabled | bit | No | | 2FA status. |
| TwoFactorSecret | nvarchar(256) | Yes | | Secret key for TOTP. |
| RoleId | int | Yes | FK -> Roles | System role. |

### `UserSessions`
Manages active login sessions and refresh tokens.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| UserUId | nvarchar(128) | No | PK, FK -> Users| User ID. |
| RefreshToken | nvarchar(512) | No | | JWT Refresh token. |
| Device | nvarchar(100) | Yes | | Device info. |
| IpAddress | nvarchar(45) | Yes | | IP address. |
| CreatedAt | datetime2 | No | | Session creation date. |
| ExpiresAt | datetime2 | No | | Session expiration. |
| IsRevoked | bit | No | Default: 0 | Revocation status. |

### `UserOtps`
Stores temporary OTP codes.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| UserUId | nvarchar(128) | No | PK, FK -> Users| User ID. |
| OtpCode | nvarchar(6) | No | | 6-digit OTP code. |
| ExpiresAt | datetime2 | No | | OTP expiration time. |

### `User2FABackupCodes`
Backup codes for 2FA recovery.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| Id | int | No | PK, Identity | Unique identifier. |
| UserUId | nvarchar(128) | No | FK -> Users | User ID. |
| CodeHash | nvarchar(256) | No | | Hashed backup code. |
| IsUsed | bit | No | Default: 0 | Usage status. |
| CreatedAt | datetime2 | No | Default: GETDATE()| Code generation date. |

---

## 2. Organization

### `Workspaces`
A workspace contains multiple boards and members.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| WorkspaceUId | nvarchar(128) | No | PK | Unique identifier. |
| Name | nvarchar(200) | No | | Workspace name. |
| Description | nvarchar(1000)| Yes | | Optional description. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Creation date. |
| Status | nvarchar(50) | No | Default: 'Active' | Status (Active/Archived). |
| OwnerUId | nvarchar(128) | No | FK -> Users | Creator/Owner of the workspace.|

### `WorkspaceMembers`
Junction table for Workspace-User relationships with roles.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| WorkspaceMemberUId | nvarchar(128) | No | PK | Unique identifier. |
| WorkspaceUId | nvarchar(128) | No | FK -> Workspaces| Workspace ID. |
| UserUId | nvarchar(128) | No | FK -> Users | User ID. |
| Role | nvarchar(50) | No | Default: 'Member'| Role (Admin/Member/Viewer). |
| JoinedAt | datetime2 | No | Default: GETDATE()| Date joined. |

---

## 3. Boards & Planning

### `Boards`
Individual project boards.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| BoardUId | nvarchar(128) | No | PK | Unique identifier. |
| BoardName | nvarchar(200) | No | | Board name. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Creation date. |
| IsPersonal | bit | No | Default: 0 | Is it a personal board? |
| Visibility | nvarchar(50) | No | Default: 'Private'| Public/Private/Workspace. |
| Status | nvarchar(50) | No | Default: 'Active' | Status. |
| BackgroundUrl | nvarchar(max) | Yes | | Board background image URL. |
| UserUId | nvarchar(128) | No | FK -> Users | Creator ID. |
| WorkspaceUId | nvarchar(128) | Yes | FK -> Workspaces| Parent workspace ID. |

### `BoardMembers`
Users explicitly added to a board.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| BoardMemberUId | nvarchar(450) | No | PK | Unique identifier. |
| BoardUId | nvarchar(128) | No | FK -> Boards | Board ID. |
| UserUId | nvarchar(128) | No | FK -> Users | User ID. |
| BoardRole | nvarchar(50) | No | Default: 'Viewer'| Role (Admin/Member/Viewer). |
| InvitedAt | datetime2 | No | Default: GETDATE() | Date invited. |

### `Lists`
Columns within a board.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| ListUId | nvarchar(128) | No | PK | Unique identifier. |
| ListName | nvarchar(200) | No | | Column name. |
| Position | int | No | | Sorting order in board. |
| Status | nvarchar(50) | No | Default: 'Active' | Status. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Creation date. |
| BoardUId | nvarchar(128) | No | FK -> Boards | Parent board ID. |

### `UserRecentBoard`
Tracks boards visited by users for quick access.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| UserRecentBoardUId | nvarchar(128) | No | PK | Unique identifier. |
| UserUId | nvarchar(128) | No | FK -> Users | User ID. |
| BoardUId | nvarchar(128) | No | FK -> Boards | Board ID. |
| LastVisitedAt | datetime2 | No | | Last visit timestamp. |

---

## 4. Tasks & Content

### `Cards`
Task cards containing details and assets.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| CardUId | nvarchar(128) | No | PK | Unique identifier. |
| Title | nvarchar(200) | No | | Card title. |
| Description | nvarchar(1000)| Yes | | Detailed description. |
| DueDate | datetime2 | Yes | | Expiration/Deadline. |
| Position | int | No | | Sorting order in list. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Creation date. |
| Status | nvarchar(50) | No | Default: 'To Do' | Card status. |
| BackgroundUrl | nvarchar(max) | Yes | | Cover image URL. |
| UserUId | nvarchar(max) | No | | Creator UID. |
| ListUId | nvarchar(128) | Yes | FK -> Lists | Parent list ID. |

### `Activities`
Logs actions performed on cards or boards.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| ActivityUId | nvarchar(128) | No | PK | Unique identifier. |
| Action | nvarchar(200) | Yes | | Action description. |
| CreatedAt | datetime2 | No | Default: GETUTCDATE()| timestamp. |
| UserUId | nvarchar(128) | Yes | FK -> Users | Actor ID. |
| CardUId | nvarchar(128) | Yes | FK -> Cards | Related card. |

### `CardLabels`
Labels attached to cards for categorization.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| CardLabelUId | nvarchar(450) | No | PK | Unique identifier. |
| CardUId | nvarchar(128) | No | FK -> Cards | Parent card ID. |
| Title | nvarchar(100) | No | | Label text. |
| ColorCode | nvarchar(20) | No | | Hex/CSS color code. |
| CreatedAt | datetime2 | No | | Creation date. |
| UpdatedAt | datetime2 | Yes | | Last update date. |

### `CardMembers`
Users assigned to specific cards.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| CardMemberUId | nvarchar(128) | No | PK | Unique identifier. |
| CardUId | nvarchar(128) | No | FK -> Cards | Card ID. |
| UserUId | nvarchar(128) | No | FK -> Users | User ID. |
| Role | nvarchar(50) | No | Default: 'Assignee'| Assignee role. |
| AssignedAt | datetime2 | No | Default: GETDATE()| Assignment date. |

### `Comments`
User comments on cards.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| CommentUId | nvarchar(128) | No | PK | Unique identifier. |
| Content | nvarchar(500) | No | | Comment text. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Creation date. |
| CardUId | nvarchar(128) | No | FK -> Cards | Card ID. |
| UserUId | nvarchar(128) | Yes | FK -> Users | Author ID. |

### `FileUrls`
Attachments linked to cards.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| FileUId | nvarchar(128) | No | PK | Unique identifier. |
| Url | nvarchar(max) | No | | File URL. |
| FileName | nvarchar(255) | No | | Original filename. |
| Description | nvarchar(max) | Yes | | File description. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Upload date. |
| CardUId | nvarchar(128) | No | FK -> Cards | Card ID. |

### `TodoItems`
Checklist items within a card.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| TodoItemUId | nvarchar(128) | No | PK | Unique identifier. |
| Content | nvarchar(300) | No | | Checklist item text. |
| IsCompleted | bit | No | | Completion status. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Creation date. |
| CardUId | nvarchar(128) | No | FK -> Cards | Card ID. |

### `UserInboxCards` (Private Inbox)
Cards personally tracked by users in their inbox.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| UserUId | nvarchar(128) | No | Composite PK, FK -> Users | User ID. |
| CardUId | nvarchar(128) | No | Composite PK, FK -> Cards | Card ID. |
| AddedAt | datetime2 | No | Default: GETDATE() | Date added to inbox. |
| Position | int | No | Default: 0 | Order in inbox. |

---

## 5. Audit & Systems

### `PermissionAudits`
Logs of permission and role changes.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| Id | int | No | PK, Identity | Unique identifier. |
| ResourceId | nvarchar(100) | No | | ID of affected resource. |
| ResourceType | nvarchar(20) | No | | Type (Workspace/Board). |
| TargetUserUId | nvarchar(100) | No | | User whose role changed. |
| ActionByUserUId| nvarchar(100) | No | | Admin who performed action.|
| ActionType | nvarchar(50) | No | | Type (Update/Add/Remove). |
| OldRole | nvarchar(50) | Yes | | Previous role. |
| NewRole | nvarchar(50) | Yes | | New role. |
| ActionAt | datetime2 | No | | timestamp. |

### `Notifications`
System notifications for users.
| Column | Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| NotiId | nvarchar(128) | No | PK | Unique identifier. |
| RecipientId | nvarchar(128) | No | FK -> Users | User receiving info. |
| ActorId | nvarchar(128) | Yes | FK -> Users | User who triggered event. |
| Type | int | No | | Notification type (Enum). |
| Title | nvarchar(140) | No | | Short summary. |
| Message | nvarchar(500) | No | | Detail message. |
| Link | nvarchar(300) | Yes | | Internal navigation link. |
| WorkspaceId | nvarchar(128) | Yes | | Context Workspace. |
| BoardId | nvarchar(128) | Yes | | Context Board. |
| ListId | nvarchar(128) | Yes | | Context List. |
| CardId | nvarchar(128) | Yes | | Context Card. |
| CreatedAt | datetime2 | No | Default: GETDATE() | Notification time. |
| Read | bit | No | Default: 0 | Read status. |
| ReadAt | datetime2 | Yes | | time consumed. |
