import 'package:apptreolon/features/activity/data/services/notification_navigation_service.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/workspace/domain/entities/workspace_entity.dart';
import 'package:apptreolon/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      loadWorkspaces: () async => const [],
    );

    final target = await service.resolve(notification(boardId: 'board-1'));

    expect(target?.routeName, AppRoutes.boardDetail);
    expect(target?.arguments, containsPair('boardId', 'board-1'));
  });

  test('tap card notification fetches board cards and opens matching card', () async {
    final service = NotificationNavigationService(
      loadCardsByBoard: (_) async => const [
        CardEntity(id: 'card-1', title: 'Card', position: 0),
      ],
      loadWorkspaces: () async => const [],
    );

    final target = await service.resolve(notification(boardId: 'board-1', cardId: 'card-1'));

    expect(target?.routeName, AppRoutes.cardDetail);
    final args = target?.arguments as Map<String, dynamic>;
    expect(args['boardId'], 'board-1');
    expect((args['card'] as CardEntity).id, 'card-1');
  });

  test('tap missing card returns null navigation target', () async {
    final service = NotificationNavigationService(
      loadCardsByBoard: (_) async => const [],
      loadWorkspaces: () async => const [],
    );

    final target = await service.resolve(notification(boardId: 'board-1', cardId: 'missing'));

    expect(target, isNull);
  });

  test('tap workspace notification opens workspace menu when workspace exists', () async {
    final workspace = WorkspaceEntity(id: 'workspace-1', name: 'Team', boards: const []);
    final service = NotificationNavigationService(
      loadCardsByBoard: (_) async => const [],
      loadWorkspaces: () async => [workspace],
    );

    final target = await service.resolve(notification(workspaceId: 'workspace-1'));

    expect(target?.routeName, AppRoutes.workspaceMenu);
    expect(target?.arguments, workspace);
  });
}
