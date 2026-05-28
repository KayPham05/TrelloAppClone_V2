import '../repositories/i_notification_repository.dart';

class MarkAsReadUseCase {
  final INotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<bool> call({required String notiId}) async {
    return await repository.markAsRead(notiId: notiId);
  }
}
