import '../repositories/i_notification_repository.dart';

class MarkAllReadUseCase {
  final INotificationRepository repository;

  MarkAllReadUseCase(this.repository);

  Future<int> call() async {
    return await repository.markAllAsRead();
  }
}
