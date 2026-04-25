import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications({required int page, required int pageSize});
  Future<bool> markAsRead({required String notiId});
  Future<int> markAllAsRead();
  Future<bool> deleteNotification({required String notiId});
}
