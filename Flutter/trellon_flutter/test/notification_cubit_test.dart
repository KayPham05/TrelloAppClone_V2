import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/activity/presentation/cubit/notification_cubit.dart';
import 'package:apptreolon/features/activity/presentation/cubit/notification_state.dart';
import 'package:apptreolon/features/activity/domain/usecases/get_notifications_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/mark_as_read_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/mark_all_read_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/delete_notification_usecase.dart';

class MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}
class MockMarkAsReadUseCase extends Mock implements MarkAsReadUseCase {}
class MockMarkAllReadUseCase extends Mock implements MarkAllReadUseCase {}
class MockDeleteNotificationUseCase extends Mock implements DeleteNotificationUseCase {}

void main() {
  late NotificationCubit cubit;
  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockMarkAsReadUseCase mockMarkAsReadUseCase;
  late MockMarkAllReadUseCase mockMarkAllReadUseCase;
  late MockDeleteNotificationUseCase mockDeleteNotificationUseCase;

  setUp(() {
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockMarkAsReadUseCase = MockMarkAsReadUseCase();
    mockMarkAllReadUseCase = MockMarkAllReadUseCase();
    mockDeleteNotificationUseCase = MockDeleteNotificationUseCase();

    cubit = NotificationCubit(
      getNotificationsUseCase: mockGetNotificationsUseCase,
      markAsReadUseCase: mockMarkAsReadUseCase,
      markAllReadUseCase: mockMarkAllReadUseCase,
      deleteNotificationUseCase: mockDeleteNotificationUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tNotification = NotificationEntity(
    id: '1',
    recipientId: 'user1',
    title: 'Test Title',
    message: 'Test message',
    createdAt: DateTime.now(),
    isRead: false,
    actorName: 'Test Actor',
    type: NotificationTypeEnum.comment,
  );

  final tNotificationRead = NotificationEntity(
    id: '2',
    recipientId: 'user1',
    title: 'Test Title 2',
    message: 'Test message 2',
    createdAt: DateTime.now(),
    isRead: true,
    actorName: 'Test Actor',
    type: NotificationTypeEnum.assign,
  );

  final tNotificationUnread = NotificationEntity(
    id: '3',
    recipientId: 'user1',
    title: 'Test Title 3',
    message: 'Test message 3',
    createdAt: DateTime.now(),
    isRead: false,
    actorName: 'Test Actor',
    type: NotificationTypeEnum.mention,
  );

  group('NotificationCubit Tests', () {
    test('initial state should be NotificationInitial', () {
      print('\n======================================================');
      print('TEST: Cubit Initial State');
      print('======================================================');
      expect(cubit.state, equals(isA<NotificationInitial>()));
      print('Result: PASSED (State is NotificationInitial)');
    });

    blocTest<NotificationCubit, NotificationState>(
      'fetchNotifications emits [Loading, Loaded] when success',
      build: () {
        print('\n======================================================');
        print('TEST: fetchNotifications - Success');
        print('======================================================');
        when(() => mockGetNotificationsUseCase.call(page: any(named: 'page'), pageSize: any(named: 'pageSize')))
            .thenAnswer((_) async => [tNotification]);
        return cubit;
      },
      act: (cubit) {
        print('[ACT] Fetching notifications (refresh: true)...');
        cubit.fetchNotifications(refresh: true);
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>().having((s) => s.notifications.length, 'length', 1),
      ],
      verify: (_) {
        print('[ASSERT] Emitted NotificationLoading -> NotificationLoaded');
        print('[ASSERT] Notification count: 1');
        print('Result: PASSED');
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'removeNotificationLocally hides notification optimistically',
      seed: () => NotificationLoaded(notifications: [tNotification]),
      build: () {
        print('\n======================================================');
        print('TEST: removeNotificationLocally (Optimistic UI)');
        print('======================================================');
        return cubit;
      },
      act: (cubit) {
        print('[ACT] Removing notification ID: 1 locally...');
        final result = cubit.removeNotificationLocally('1');
        print('[LOG] Returned tuple: (Entity: ${result?.$1.id}, Index: ${result?.$2})');
      },
      expect: () => [
        isA<NotificationLoaded>().having((s) => s.notifications.isEmpty, 'isEmpty', true),
      ],
      verify: (_) {
        print('[ASSERT] Notification list is now EMPTY');
        print('Result: PASSED');
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'undoDeleteNotification restores notification at correct index',
      seed: () => NotificationLoaded(notifications: [tNotificationRead]),
      build: () {
        print('\n======================================================');
        print('TEST: undoDeleteNotification (Restore Logic)');
        print('======================================================');
        return cubit;
      },
      act: (cubit) {
        print('[ACT] Undoing delete: Restore ID 1 to Index 0...');
        cubit.undoDeleteNotification(tNotification, 0);
      },
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 2)
            .having((s) => s.notifications[0].id, 'first item id', '1'),
      ],
      verify: (_) {
        print('[ASSERT] List size increased to 2');
        print('[ASSERT] Index 0 is ID: 1');
        print('Result: PASSED');
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'confirmDeleteNotification calls API and does not emit state if successful',
      seed: () => NotificationLoaded(notifications: []), 
      build: () {
        print('\n======================================================');
        print('TEST: confirmDeleteNotification (API Success)');
        print('======================================================');
        when(() => mockDeleteNotificationUseCase.call(notiId: any(named: 'notiId'))).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) {
        print('[ACT] Confirming delete for ID 1 (already hidden)...');
        cubit.confirmDeleteNotification('1', tNotification, 0);
      },
      expect: () => [],
      verify: (_) {
        verify(() => mockDeleteNotificationUseCase.call(notiId: '1')).called(1);
        print('[ASSERT] Delete API was called with ID: 1');
        print('[ASSERT] No further state changes (UI remains clean)');
        print('Result: PASSED');
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'confirmDeleteNotification restores notification on API failure',
      seed: () => NotificationLoaded(notifications: []),
      build: () {
        print('\n======================================================');
        print('TEST: confirmDeleteNotification (API Failure -> Auto Restore)');
        print('======================================================');
        when(() => mockDeleteNotificationUseCase.call(notiId: any(named: 'notiId'))).thenThrow(Exception('Network Error'));
        return cubit;
      },
      act: (cubit) {
        print('[ACT] Confirming delete for ID 1 but API fails...');
        cubit.confirmDeleteNotification('1', tNotification, 0);
      },
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 1),
      ],
      verify: (_) {
        verify(() => mockDeleteNotificationUseCase.call(notiId: '1')).called(1);
        print('[ASSERT] API failed, Cubit auto-called undoDeleteNotification');
        print('[ASSERT] Notification restored to UI');
        print('Result: PASSED');
      },
    );

    test('unreadCount should return correct number of unread notifications', () {
      print('\n======================================================');
      print('TEST: unreadCount Computation');
      print('======================================================');
      cubit.emit(NotificationLoaded(notifications: [
        tNotification,
        tNotificationRead,
        tNotificationUnread,
      ]));
      print('[DATA] Notifications: [ID1: Unread, ID2: Read, ID3: Unread]');
      print('[ACT] Checking unreadCount...');
      expect(cubit.unreadCount, equals(2));
      print('Result: PASSED (Count is 2)');
    });

    blocTest<NotificationCubit, NotificationState>(
      'reset sets state back to NotificationInitial',
      seed: () => NotificationLoaded(notifications: [tNotification]),
      build: () {
        print('\n======================================================');
        print('TEST: reset Cubit (Logout logic)');
        print('======================================================');
        return cubit;
      },
      act: (cubit) {
        print('[ACT] Calling cubit.reset()...');
        cubit.reset();
      },
      expect: () => [
        isA<NotificationInitial>(),
      ],
      verify: (_) {
        print('[ASSERT] State is back to NotificationInitial');
        print('Result: PASSED');
      },
    );
  });
}
