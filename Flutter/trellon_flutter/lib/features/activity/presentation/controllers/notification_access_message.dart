import '../../domain/entities/notification_entity.dart';

class NotificationAccessMessage {
  static const accessDenied =
      'Bạn không còn quyền truy cập nội dung thông báo này.';
  static const invalidTarget = 'Không thể mở nội dung thông báo này.';

  const NotificationAccessMessage._();

  static String forNotification(NotificationEntity notification) {
    return switch (notification.type) {
      NotificationTypeEnum.boardMemberRemoved ||
      NotificationTypeEnum.workspaceMemberRemoved => accessDenied,
      _ => invalidTarget,
    };
  }
}
