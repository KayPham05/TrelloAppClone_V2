namespace TodoAppAPI.Models
{
    public enum NotificationType
    {
        Comment = 0,
        Assign = 1,
        Move = 2,
        Due = 3,
        Mention = 4,
        Workspace = 5,
        Board = 6,
        CardUnassigned = 7,
        BoardMemberAdded = 8,
        BoardMemberRemoved = 9,
        BoardRoleChanged = 10,
        WorkspaceMemberAdded = 11,
        WorkspaceMemberRemoved = 12,
        WorkspaceRoleChanged = 13,
        DueDateChanged = 14,
        DueDateReminder = 15,
        CardArchived = 16,
        AttachmentAdded = 17,
        AttachmentRemoved = 18,
        CardRenamed = 19,
        WorkspaceRenamed = 20
    }
}
