import '../entities/notification_entity.dart';
import '../repositories/i_notification_repository.dart';

class GetNotificationsUseCase {
  final INotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<NotificationPageEntity> call({
    required int page,
    required int pageSize,
    required NotificationTab tab,
  }) async {
    return await repository.getNotifications(page: page, pageSize: pageSize, tab: tab);
  }
}
