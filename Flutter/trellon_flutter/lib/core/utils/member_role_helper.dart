import 'package:flutter/material.dart';

/// Dùng chung để map role string → Color / Icon / label hiển thị
/// cho tất cả 3 lớp: Workspace, Board, Card
class MemberRoleHelper {
  static const _workspaceRoles = ['Owner', 'Admin', 'Member', 'Viewer'];
  static const _boardRoles     = ['Owner', 'Admin', 'Editor', 'Viewer'];
  static const _cardRoles      = ['Assignee', 'Observer'];

  static Color colorForRole(String role) {
    switch (role) {
      case 'Owner':    return const Color(0xFFD97706); // amber-600
      case 'Admin':    return const Color(0xFF0052CC); // trello-blue
      case 'Editor':   return const Color(0xFF16A34A); // green-600
      case 'Reviewer': return const Color(0xFF7C3AED); // violet-600
      case 'Assignee': return const Color(0xFF0284C7); // sky-600
      case 'Viewer':
      case 'Observer': return const Color(0xFF64748B); // slate-500
      default:         return const Color(0xFF515F76);
    }
  }

  static IconData iconForRole(String role) {
    switch (role) {
      case 'Owner':    return Icons.star_rounded;
      case 'Admin':    return Icons.admin_panel_settings_rounded;
      case 'Editor':   return Icons.edit_rounded;
      case 'Reviewer': return Icons.rate_review_rounded;
      case 'Assignee': return Icons.assignment_ind_rounded;
      case 'Viewer':
      case 'Observer': return Icons.visibility_rounded;
      default:         return Icons.person_rounded;
    }
  }

  static bool canManageMembers(String currentUserRole) {
    // This is a simplified check, preferably use AuthorizationService
    return currentUserRole == 'Owner' || currentUserRole == 'Admin';
  }

  static List<String> rolesForScope(MemberScope scope) {
    switch (scope) {
      case MemberScope.workspace: return _workspaceRoles;
      case MemberScope.board:     return _boardRoles;
      case MemberScope.card:      return _cardRoles;
    }
  }
}

enum MemberScope { workspace, board, card }
