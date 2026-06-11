import 'package:apptreolon/features/activity/data/models/notification_model.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationModel.fromJson', () {
    test('parses full payload with all optional fields', () {
      final json = {
        'notiId': 'noti-abc',
        'recipientId': 'user-1',
        'actorId': 'user-2',
        'actorName': 'Alice',
        'type': 4,
        'title': 'Mentioned you',
        'message': 'Alice mentioned you in a card',
        'link': 'https://example.com',
        'workspaceId': 'ws-1',
        'boardId': 'board-1',
        'listId': 'list-1',
        'cardId': 'card-1',
        'createdAt': '2026-05-25T10:00:00Z',
        'read': true,
        'readAt': '2026-05-25T11:00:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'noti-abc');
      expect(model.recipientId, 'user-1');
      expect(model.actorId, 'user-2');
      expect(model.actorName, 'Alice');
      expect(model.type, NotificationTypeEnum.mention);
      expect(model.workspaceId, 'ws-1');
      expect(model.boardId, 'board-1');
      expect(model.listId, 'list-1');
      expect(model.cardId, 'card-1');
      expect(model.isRead, true);
      expect(model.readAt, DateTime.parse('2026-05-25T11:00:00Z'));
    });

    test('falls back to actor.userName when actorName is absent', () {
      final json = {
        'notiId': 'noti-xyz',
        'recipientId': 'user-1',
        'actor': {'userName': 'Bob'},
        'type': 1,
        'title': 'Assigned',
        'message': 'You were assigned',
        'createdAt': '2026-05-25T10:00:00Z',
        'read': false,
      };

      final model = NotificationModel.fromJson(json);

      expect(model.actorName, 'Bob');
    });

    test('maps unknown type integer to default comment enum', () {
      final json = {
        'notiId': 'noti-999',
        'recipientId': 'user-1',
        'type': 999,
        'title': 'Unknown',
        'message': 'Unknown event',
        'createdAt': '2026-05-25T10:00:00Z',
        'read': false,
      };

      final model = NotificationModel.fromJson(json);

      expect(model.type, NotificationTypeEnum.comment);
    });

    test('optional context fields default to null when absent', () {
      final json = {
        'notiId': 'noti-min',
        'recipientId': 'user-1',
        'type': 0,
        'title': 'Comment',
        'message': 'Someone commented',
        'createdAt': '2026-05-25T10:00:00Z',
        'read': false,
      };

      final model = NotificationModel.fromJson(json);

      expect(model.workspaceId, isNull);
      expect(model.boardId, isNull);
      expect(model.listId, isNull);
      expect(model.cardId, isNull);
      expect(model.readAt, isNull);
      expect(model.actorName, isNull);
    });
  });
}
