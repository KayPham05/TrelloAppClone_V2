import '../../../../routes.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../../../workspace/domain/entities/workspace_entity.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationNavigationTarget {
  final String routeName;
  final Object arguments;

  const NotificationNavigationTarget({
    required this.routeName,
    required this.arguments,
  });
}

class NotificationNavigationService {
  final Future<List<CardEntity>> Function(String boardId) loadCardsByBoard;
  final Future<List<WorkspaceEntity>> Function() loadWorkspaces;

  const NotificationNavigationService({
    required this.loadCardsByBoard,
    required this.loadWorkspaces,
  });

  Future<NotificationNavigationTarget?> resolve(
    NotificationEntity notification,
  ) async {
    final boardId = _blankToNull(notification.boardId);
    final cardId = _blankToNull(notification.cardId);
    final workspaceId = _blankToNull(notification.workspaceId);

    if (boardId != null && cardId != null) {
      final boardTarget = await _resolveAccessibleBoard(boardId, workspaceId);
      if (boardTarget == null) return null;

      final cards = await loadCardsByBoard(boardId);
      final card = _firstOrNull(cards.where((c) => c.id == cardId));
      if (card == null) return null;
      return NotificationNavigationTarget(
        routeName: AppRoutes.cardDetail,
        arguments: {'card': card, 'boardId': boardId},
      );
    }

    if (boardId != null) {
      final boardTarget = await _resolveAccessibleBoard(boardId, workspaceId);
      if (boardTarget == null) return null;

      return NotificationNavigationTarget(
        routeName: AppRoutes.boardDetail,
        arguments: {
          'boardId': boardId,
          'boardName': boardTarget.name,
          'workspaceId': boardTarget.workspaceId,
        },
      );
    }

    if (workspaceId != null) {
      final workspaces = await loadWorkspaces();
      final workspace = _firstOrNull(
        workspaces.where((w) => w.id == workspaceId),
      );
      if (workspace == null) return null;
      return NotificationNavigationTarget(
        routeName: AppRoutes.workspaceMenu,
        arguments: workspace,
      );
    }

    return null;
  }

  Future<_AccessibleBoardTarget?> _resolveAccessibleBoard(
    String boardId,
    String? workspaceId,
  ) async {
    final workspaces = await loadWorkspaces();
    final visibleWorkspaces = workspaceId == null
        ? workspaces
        : workspaces.where((workspace) => workspace.id == workspaceId);

    for (final workspace in visibleWorkspaces) {
      final board = _firstOrNull(
        workspace.boards.where((b) => b.id == boardId),
      );
      if (board != null) {
        return _AccessibleBoardTarget(
          name: board.name,
          workspaceId: board.workspaceId ?? workspace.id,
        );
      }
    }

    return null;
  }

  static T? _firstOrNull<T>(Iterable<T> values) {
    final iterator = values.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }

  static String? _blankToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}

class _AccessibleBoardTarget {
  final String name;
  final String? workspaceId;

  const _AccessibleBoardTarget({required this.name, required this.workspaceId});
}
