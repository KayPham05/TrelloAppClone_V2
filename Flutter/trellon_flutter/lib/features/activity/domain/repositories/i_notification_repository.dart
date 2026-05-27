import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<NotificationPageEntity> getNotifications({
    required int page,
    required int pageSize,
    required NotificationTab tab,
  });
  Future<bool> markAsRead({required String notiId});
  Future<int> markAllAsRead();
  Future<bool> deleteNotification({required String notiId});
}
