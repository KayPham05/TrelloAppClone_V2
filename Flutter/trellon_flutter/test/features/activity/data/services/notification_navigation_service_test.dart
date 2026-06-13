import 'package:apptreolon/features/activity/data/services/notification_navigation_service.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/board/domain/entities/board_entity.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/workspace/domain/entities/workspace_entity.dart';
import 'package:apptreolon/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testBoardId = 'board-1';
  const testWorkspaceId = 'workspace-1';

  const board = BoardEntity(
    id: testBoardId,
    name: 'Board',
    visibility: 'Workspace',
    isPersonal: false,
    workspaceId: testWorkspaceId,
    workspaceName: 'Team',
  );

  const workspaceWithBoard = WorkspaceEntity(
    id: testWorkspaceId,
    name: 'Team',
    boards: [board],
  );

  NotificationEntity notification({
    String? workspaceId,
    String? boardId,
    String? cardId,
  }) {
    return NotificationEntity(
      id: 'n1',
      recipientId: 'u1',
      type: NotificationTypeEnum.assign,
      title: 'Target title',
      message: 'Target message',
      workspaceId: workspaceId,
      boardId: boardId,
      cardId: cardId,
      createdAt: DateTime(2026, 5, 26),
      isRead: false,
    );
  }

  test('tap board notification builds board-detail navigation args', () async {
    final service = NotificationNavigationService(
      loadCardsByBoard: (_) async => const [],
      loadWorkspaces: () async => const [workspaceWithBoard],
    );

    final target = await service.resolve(
      notification(workspaceId: testWorkspaceId, boardId: testBoardId),
    );

    expect(target?.routeName, AppRoutes.boardDetail);
    expect(target?.arguments, containsPair('boardId', testBoardId));
  });

  test(
    'tap board notification returns null when board is no longer accessible',
    () async {
      final workspace = WorkspaceEntity(
        id: testWorkspaceId,
        name: 'Team',
        boards: const [],
      );
      final service = NotificationNavigationService(
        loadCardsByBoard: (_) async => const [],
        loadWorkspaces: () async => [workspace],
      );

      final target = await service.resolve(
        notification(workspaceId: testWorkspaceId, boardId: 'board-removed'),
      );

      expect(target, isNull);
    },
  );

  test(
    'tap card notification fetches board cards and opens matching card',
    () async {
      final service = NotificationNavigationService(
        loadCardsByBoard: (_) async => const [
          CardEntity(id: 'card-1', title: 'Card', position: 0),
        ],
        loadWorkspaces: () async => const [workspaceWithBoard],
      );

      final target = await service.resolve(
        notification(
          workspaceId: testWorkspaceId,
          boardId: testBoardId,
          cardId: 'card-1',
        ),
      );

      expect(target?.routeName, AppRoutes.cardDetail);
      final args = target?.arguments as Map<String, dynamic>;
      expect(args['boardId'], testBoardId);
      expect((args['card'] as CardEntity).id, 'card-1');
    },
  );

  test('tap missing card returns null navigation target', () async {
    final service = NotificationNavigationService(
      loadCardsByBoard: (_) async => const [],
      loadWorkspaces: () async => const [workspaceWithBoard],
    );

    final target = await service.resolve(
      notification(
        workspaceId: testWorkspaceId,
        boardId: testBoardId,
        cardId: 'missing',
      ),
    );

    expect(target, isNull);
  });

  test(
    'tap workspace notification opens workspace menu when workspace exists',
    () async {
      final workspace = WorkspaceEntity(
        id: testWorkspaceId,
        name: 'Team',
        boards: const [],
      );
      final service = NotificationNavigationService(
        loadCardsByBoard: (_) async => const [],
        loadWorkspaces: () async => [workspace],
      );

      final target = await service.resolve(
        notification(workspaceId: testWorkspaceId),
      );

      expect(target?.routeName, AppRoutes.workspaceMenu);
      expect(target?.arguments, workspace);
    },
  );

  test(
    'tap workspace notification returns null when workspace is no longer accessible',
    () async {
      final service = NotificationNavigationService(
        loadCardsByBoard: (_) async => const [],
        loadWorkspaces: () async => const [],
      );

      final target = await service.resolve(
        notification(workspaceId: 'workspace-removed'),
      );

      expect(target, isNull);
    },
  );
}
