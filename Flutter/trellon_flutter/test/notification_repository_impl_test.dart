import 'package:apptreolon/features/activity/data/datasources/notification_remote_datasource.dart';
import 'package:apptreolon/features/activity/data/models/notification_model.dart';
import 'package:apptreolon/features/activity/data/repositories/notification_repository_impl.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/activity/domain/repositories/i_notification_repository.dart';
import 'package:apptreolon/features/activity/domain/usecases/delete_notification_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRemoteDataSource extends Mock implements NotificationRemoteDataSource {}

void main() {
  late MockNotificationRemoteDataSource remoteDataSource;
  late NotificationRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockNotificationRemoteDataSource();
    repository = NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('NotificationRepositoryImpl', () {
    test('getNotifications delegates correctly to remoteDataSource', () async {
      final expectedPage = NotificationPageModel(
        items: [],
        unreadCount: 5,
        hasMore: false,
      );

      when(
        () => remoteDataSource.getNotifications(
          page: 1,
          pageSize: 20,
          tab: 'all',
        ),
      ).thenAnswer((_) async => expectedPage);

      final result = await repository.getNotifications(
        page: 1,
        pageSize: 20,
        tab: NotificationTab.all,
      );

      expect(result, expectedPage);
      verify(() => remoteDataSource.getNotifications(page: 1, pageSize: 20, tab: 'all')).called(1);
    });

    test('markAsRead delegates correctly to remoteDataSource', () async {
      when(() => remoteDataSource.markAsRead(notiId: '123')).thenAnswer((_) async => true);

      final result = await repository.markAsRead(notiId: '123');

      expect(result, true);
      verify(() => remoteDataSource.markAsRead(notiId: '123')).called(1);
    });

    test('markAllAsRead delegates correctly to remoteDataSource', () async {
      when(() => remoteDataSource.markAllAsRead()).thenAnswer((_) async => 4);

      final result = await repository.markAllAsRead();

      expect(result, 4);
      verify(() => remoteDataSource.markAllAsRead()).called(1);
    });

    test('deleteNotification delegates correctly to remoteDataSource', () async {
      when(() => remoteDataSource.deleteNotification(notiId: '456')).thenAnswer((_) async => true);

      final result = await repository.deleteNotification(notiId: '456');

      expect(result, true);
      verify(() => remoteDataSource.deleteNotification(notiId: '456')).called(1);
    });
  });

  group('DeleteNotificationUseCase', () {
    late DeleteNotificationUseCase usecase;

    setUp(() {
      usecase = DeleteNotificationUseCase(repository);
    });

    test('invokes deleteNotification on repository', () async {
      when(() => remoteDataSource.deleteNotification(notiId: 'abc')).thenAnswer((_) async => true);

      final result = await usecase.call(notiId: 'abc');

      expect(result, true);
      verify(() => remoteDataSource.deleteNotification(notiId: 'abc')).called(1);
    });
  });
}
