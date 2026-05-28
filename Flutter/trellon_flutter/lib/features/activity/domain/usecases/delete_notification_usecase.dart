import '../repositories/i_notification_repository.dart';

class DeleteNotificationUseCase {
  final INotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<bool> call({required String notiId}) async {
    return await repository.deleteNotification(notiId: notiId);
  }
}
