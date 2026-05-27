import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/activity/domain/repositories/i_notification_repository.dart';
import 'package:apptreolon/features/activity/domain/usecases/delete_notification_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/get_notifications_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/mark_all_read_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/mark_as_read_usecase.dart';
import 'package:apptreolon/features/activity/presentation/cubit/notification_cubit.dart';
import 'package:apptreolon/features/activity/presentation/cubit/notification_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements INotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late NotificationCubit cubit;

  final unreadNotification = NotificationEntity(
    id: '1',
    recipientId: 'user1',
    title: 'Assigned to card',
    message: 'You were added to a card',
    createdAt: DateTime(2026, 5, 25, 10),
    isRead: false,
    actorName: 'Test Actor',
    type: NotificationTypeEnum.assign,
  );

  final readNotification = NotificationEntity(
    id: '2',
    recipientId: 'user1',
    title: 'Mentioned',
    message: 'You were mentioned',
    createdAt: DateTime(2026, 5, 25, 11),
    isRead: true,
    actorName: 'Test Actor',
    type: NotificationTypeEnum.mention,
  );

  setUp(() {
    repository = MockNotificationRepository();
    cubit = NotificationCubit(
      getNotificationsUseCase: GetNotificationsUseCase(repository),
      markAsReadUseCase: MarkAsReadUseCase(repository),
      markAllReadUseCase: MarkAllReadUseCase(repository),
      deleteNotificationUseCase: DeleteNotificationUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  group('NotificationCubit', () {
    test('initial state is NotificationInitial', () {
      expect(cubit.state, isA<NotificationInitial>());
    });

    blocTest<NotificationCubit, NotificationState>(
      'fetchNotifications stores server unreadCount and tab',
      build: () {
        when(
          () => repository.getNotifications(
            page: 1,
            pageSize: 20,
            tab: NotificationTab.sentToMe,
          ),
        ).thenAnswer(
          (_) async => NotificationPageEntity(
            items: [unreadNotification],
            unreadCount: 9,
            hasMore: false,
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchNotifications(refresh: true, tab: NotificationTab.sentToMe),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 1)
            .having((s) => s.unreadCount, 'unreadCount', 9)
            .having((s) => s.tab, 'tab', NotificationTab.sentToMe),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyRealtimeNotification prepends new notification and increments unread count',
      seed: () => NotificationLoaded(
        notifications: [readNotification],
        unreadCount: 2,
        tab: NotificationTab.all,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyRealtimeNotification(unreadNotification),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.first.id, 'first id', '1')
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyRealtimeNotification ignores duplicate ids',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 2,
        tab: NotificationTab.all,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyRealtimeNotification(unreadNotification),
      expect: () => [],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyRealtimeNotification does not show unread items on read tab',
      seed: () => NotificationLoaded(
        notifications: [readNotification],
        unreadCount: 2,
        tab: NotificationTab.read,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyRealtimeNotification(unreadNotification),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.map((n) => n.id).toList(), 'ids', ['2'])
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyRealtimeNotification does not show read items on sent-to-me tab',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 2,
        tab: NotificationTab.sentToMe,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyRealtimeNotification(readNotification),
      expect: () => [],
      verify: (cubit) {
        final state = cubit.state as NotificationLoaded;
        expect(state.notifications.map((n) => n.id).toList(), ['1']);
        expect(state.unreadCount, 2);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead updates item and decrements unread count',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 4,
        tab: NotificationTab.all,
      ),
      build: () {
        when(() => repository.markAsRead(notiId: '1')).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.markAsRead('1'),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.first.isRead, 'isRead', true)
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead removes item from sent-to-me tab',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 4,
        tab: NotificationTab.sentToMe,
      ),
      build: () {
        when(() => repository.markAsRead(notiId: '1')).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.markAsRead('1'),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications, 'notifications', isEmpty)
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyNotificationRead removes item from sent-to-me tab',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 4,
        tab: NotificationTab.sentToMe,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyNotificationRead('1'),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications, 'notifications', isEmpty)
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyNotificationReadAll marks loaded read-tab notifications read and zeroes unreadCount',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 4,
        tab: NotificationTab.read,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyNotificationReadAll(),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 1)
            .having((s) => s.notifications.first.isRead, 'isRead', true)
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyNotificationReadAll clears sent-to-me tab and zeroes unreadCount',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 4,
        tab: NotificationTab.sentToMe,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyNotificationReadAll(),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications, 'notifications', isEmpty)
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyNotificationReadAll marks loaded all-tab notifications read and zeroes unreadCount',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification, readNotification],
        unreadCount: 4,
        tab: NotificationTab.all,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyNotificationReadAll(),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 2)
            .having((s) => s.notifications.every((n) => n.isRead), 'all read', true)
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyNotificationReadAll is no-op outside NotificationLoaded',
      build: () => cubit,
      act: (cubit) => cubit.applyNotificationReadAll(),
      expect: () => [],
    );
  });
}
