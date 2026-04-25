import '../entities/notification_entity.dart';
import '../repositories/i_notification_repository.dart';

class GetNotificationsUseCase {
  final INotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call({required int page, required int pageSize}) async {
    return await repository.getNotifications(page: page, pageSize: pageSize);
  }
}
