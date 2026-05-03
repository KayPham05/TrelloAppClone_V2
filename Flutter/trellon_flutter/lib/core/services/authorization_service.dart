import '../constants/role_constants.dart';

class AuthorizationService {
  static final AuthorizationService _instance = AuthorizationService._internal();
  factory AuthorizationService() => _instance;
  AuthorizationService._internal();

  // Basic check for Workspace permissions
  bool canManageWorkspace(String? userRole, {String? userUId}) {
    if (userRole == null) return false;
    final priority = RoleConstants.getWorkspaceRolePriority(userRole);
    return priority >= RoleConstants.getWorkspaceRolePriority(RoleConstants.workspaceAdmin);
  }

  bool canInviteToWorkspace(String? userRole, {String? userUId}) {
    return canManageWorkspace(userRole, userUId: userUId);
  }

  // Basic check for Board permissions
  bool canManageBoard(String? boardRole, String? workspaceRole, {String? userUId}) {
    // If user is Workspace Admin/Owner, they can manage boards
    if (canManageWorkspace(workspaceRole, userUId: userUId)) return true;
    
    if (boardRole == null) return false;
    final priority = RoleConstants.getBoardRolePriority(boardRole);
    return priority >= RoleConstants.getBoardRolePriority(RoleConstants.boardAdmin);
  }

  bool canInviteToBoard(String? boardRole, String? workspaceRole, {String? userUId}) {
    return canManageBoard(boardRole, workspaceRole, userUId: userUId);
  }

  bool canEditBoard(String? boardRole, String? workspaceRole, {String? userUId}) {
    if (canManageWorkspace(workspaceRole, userUId: userUId)) return true;
    if (boardRole == null) return false;
    final priority = RoleConstants.getBoardRolePriority(boardRole);
    return priority >= RoleConstants.getBoardRolePriority(RoleConstants.boardEditor);
  }

  // Card permissions
  bool canManageCards(String? boardRole, String? workspaceRole, {String? userUId}) {
    return canEditBoard(boardRole, workspaceRole, userUId: userUId);
  }

  // Helper to check if a user has at least a specific role
  bool hasMinimumWorkspaceRole(String? userRole, String minRole, {String? userUId}) {
    if (userRole == null) return false;
    return RoleConstants.getWorkspaceRolePriority(userRole) >= 
           RoleConstants.getWorkspaceRolePriority(minRole);
  }

  bool hasMinimumBoardRole(String? boardRole, String minRole, {String? userUId}) {
    if (boardRole == null) return false;
    return RoleConstants.getBoardRolePriority(boardRole) >= 
           RoleConstants.getBoardRolePriority(minRole);
  }
}
