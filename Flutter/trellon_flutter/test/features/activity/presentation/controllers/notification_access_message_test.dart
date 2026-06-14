import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/activity/presentation/controllers/notification_access_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  NotificationEntity notification(NotificationTypeEnum type) {
    return NotificationEntity(
      id: 'n1',
      recipientId: 'u1',
      type: type,
      title: 'Bạn đã bị xóa khỏi board',
      message: 'Bạn đã bị Nguyễn An xóa khỏi Sprint Board.',
      createdAt: DateTime(2026, 6, 12),
      isRead: false,
    );
  }

  test(
    'removed board or workspace notifications use access denied popup message',
    () {
      expect(
        NotificationAccessMessage.forNotification(
          notification(NotificationTypeEnum.boardMemberRemoved),
        ),
        'Bạn không còn quyền truy cập nội dung thông báo này.',
      );

      expect(
        NotificationAccessMessage.forNotification(
          notification(NotificationTypeEnum.workspaceMemberRemoved),
        ),
        'Bạn không còn quyền truy cập nội dung thông báo này.',
      );
    },
  );

  test('invalid navigation target uses cannot open popup message', () {
    expect(
      NotificationAccessMessage.invalidTarget,
      'Không thể mở nội dung thông báo này.',
    );
  });
}
