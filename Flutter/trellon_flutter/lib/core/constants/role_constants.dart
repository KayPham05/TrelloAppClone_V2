class RoleConstants {
  // Workspace Roles
  static const String workspaceOwner = 'Owner';
  static const String workspaceAdmin = 'Admin';
  static const String workspaceMember = 'Member';
  static const String workspaceViewer = 'Viewer';

  // Board Roles
  static const String boardOwner = 'Owner';
  static const String boardAdmin = 'Admin';
  static const String boardEditor = 'Editor';
  static const String boardViewer = 'Viewer';

  // Helper to check priorities
  static int getWorkspaceRolePriority(String role) {
    switch (role) {
      case workspaceOwner:
        return 4;
      case workspaceAdmin:
        return 3;
      case workspaceMember:
        return 2;
      case workspaceViewer:
        return 1;
      default:
        return 0;
    }
  }

  static int getBoardRolePriority(String role) {
    switch (role) {
      case boardOwner:
        return 4;
      case boardAdmin:
        return 3;
      case boardEditor:
        return 2;
      case boardViewer:
        return 1;
      default:
        return 0;
    }
  }
}
