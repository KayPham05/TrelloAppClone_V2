import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications({required int page, required int pageSize}) async {
    final models = await remoteDataSource.getNotifications(page: page, pageSize: pageSize);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> markAsRead({required String notiId}) async {
    return await remoteDataSource.markAsRead(notiId: notiId);
  }

  @override
  Future<int> markAllAsRead() async {
    return await remoteDataSource.markAllAsRead();
  }

  @override
  Future<bool> deleteNotification({required String notiId}) async {
    return await remoteDataSource.deleteNotification(notiId: notiId);
  }
}
