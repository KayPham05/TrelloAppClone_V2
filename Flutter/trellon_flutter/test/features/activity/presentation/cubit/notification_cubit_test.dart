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

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

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
      act: (cubit) => cubit.fetchNotifications(
        refresh: true,
        tab: NotificationTab.sentToMe,
      ),
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
            .having((s) => s.notifications.map((n) => n.id).toList(), 'ids', [
              '2',
            ])
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
      'applyRealtimeNotification shows new core card direct notifications on sent-to-me tab',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 2,
        tab: NotificationTab.sentToMe,
      ),
      build: () => cubit,
      act: (cubit) => cubit.applyRealtimeNotification(
        NotificationEntity(
          id: 'card-archived-1',
          recipientId: 'user1',
          title: 'Thẻ đã được lưu trữ',
          message: 'Nguyễn An đã lưu trữ Important card',
          createdAt: DateTime(2026, 6, 12, 10),
          isRead: false,
          type: NotificationTypeEnum.cardArchived,
        ),
      ),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.map((n) => n.id).toList(), 'ids', [
              'card-archived-1',
              '1',
            ])
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead updates item and decrements unread count',
      seed: () => NotificationLoaded(
        notifications: [unreadNotification],
        unreadCount: 4,
        tab: NotificationTab.all,
      ),
      build: () {
        when(
          () => repository.markAsRead(notiId: '1'),
        ).thenAnswer((_) async => true);
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
        when(
          () => repository.markAsRead(notiId: '1'),
        ).thenAnswer((_) async => true);
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
            .having(
              (s) => s.notifications.every((n) => n.isRead),
              'all read',
              true,
            )
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'applyNotificationReadAll is no-op outside NotificationLoaded',
      build: () => cubit,
      act: (cubit) => cubit.applyNotificationReadAll(),
      expect: () => [],
    );

    group('markAllAsRead', () {
      blocTest<NotificationCubit, NotificationState>(
        'markAllAsRead calls markAllReadUseCase, updates state and returns true',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 4,
          tab: NotificationTab.all,
        ),
        build: () {
          when(() => repository.markAllAsRead()).thenAnswer((_) async => 1);
          return cubit;
        },
        act: (cubit) async {
          final res = await cubit.markAllAsRead();
          expect(res, true);
        },
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications.first.isRead, 'isRead', true)
              .having((s) => s.unreadCount, 'unreadCount', 0),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'markAllAsRead sentToMe tab clears notifications',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 4,
          tab: NotificationTab.sentToMe,
        ),
        build: () {
          when(() => repository.markAllAsRead()).thenAnswer((_) async => 1);
          return cubit;
        },
        act: (cubit) => cubit.markAllAsRead(),
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications, 'notifications', isEmpty)
              .having((s) => s.unreadCount, 'unreadCount', 0),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'markAllAsRead returns false on failure and does not change state',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 4,
          tab: NotificationTab.all,
        ),
        build: () {
          when(() => repository.markAllAsRead()).thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) async {
          final res = await cubit.markAllAsRead();
          expect(res, false);
        },
        expect: () => [],
      );
    });

    group('Deletion and Undo', () {
      blocTest<NotificationCubit, NotificationState>(
        'removeNotificationLocally removes notification and decrements unreadCount',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification, readNotification],
          unreadCount: 2,
          tab: NotificationTab.all,
        ),
        build: () => cubit,
        act: (cubit) {
          final res = cubit.removeNotificationLocally('1');
          expect(res, isNotNull);
          expect(res!.$1.id, '1');
          expect(res.$2, 0);
        },
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications.length, 'length', 1)
              .having((s) => s.notifications.first.id, 'remaining', '2')
              .having((s) => s.unreadCount, 'unreadCount', 1),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'undoDeleteNotification inserts notification back at original index and restores unreadCount',
        seed: () => NotificationLoaded(
          notifications: [readNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () => cubit,
        act: (cubit) => cubit.undoDeleteNotification(unreadNotification, 0),
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications.length, 'length', 2)
              .having((s) => s.notifications.first.id, 'first id', '1')
              .having((s) => s.unreadCount, 'unreadCount', 2),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'confirmDeleteNotification success calls deleteNotificationUseCase and does not undo',
        seed: () => NotificationLoaded(
          notifications: [readNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () {
          when(
            () => repository.deleteNotification(notiId: '1'),
          ).thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) async {
          final res = await cubit.confirmDeleteNotification(
            '1',
            unreadNotification,
            0,
          );
          expect(res, true);
        },
        expect: () => [],
        verify: (_) {
          verify(() => repository.deleteNotification(notiId: '1')).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'confirmDeleteNotification failure triggers undoDeleteNotification',
        seed: () => NotificationLoaded(
          notifications: [readNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () {
          when(
            () => repository.deleteNotification(notiId: '1'),
          ).thenAnswer((_) async => false);
          return cubit;
        },
        act: (cubit) async {
          final res = await cubit.confirmDeleteNotification(
            '1',
            unreadNotification,
            0,
          );
          expect(res, false);
        },
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications.length, 'length', 2)
              .having((s) => s.unreadCount, 'unreadCount', 2),
        ],
      );
    });

    group('Realtime changes and updates', () {
      blocTest<NotificationCubit, NotificationState>(
        'applyNotificationDeleted removes item',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () => cubit,
        act: (cubit) => cubit.applyNotificationDeleted('1'),
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications, 'notifications', isEmpty)
              .having(
                (s) => s.unreadCount,
                'unreadCount',
                1,
              ), // deleted from real-time keeps unread count or user-updated count
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'applyUnreadCount updates the unread count in loaded state',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () => cubit,
        act: (cubit) => cubit.applyUnreadCount(15),
        expect: () => [
          isA<NotificationLoaded>().having(
            (s) => s.unreadCount,
            'unreadCount',
            15,
          ),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'reset emits NotificationInitial',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () => cubit,
        act: (cubit) => cubit.reset(),
        expect: () => [isA<NotificationInitial>()],
      );
    });

    group('fetchNotifications pagination and errors', () {
      blocTest<NotificationCubit, NotificationState>(
        'fetchNotifications appends and dedupes items when loading more',
        seed: () => NotificationLoaded(
          notifications: [unreadNotification],
          unreadCount: 1,
          tab: NotificationTab.all,
        ),
        build: () {
          when(
            () => repository.getNotifications(
              page: 1,
              pageSize: 20,
              tab: NotificationTab.all,
            ),
          ).thenAnswer(
            (_) async => NotificationPageEntity(
              items: [unreadNotification, readNotification],
              unreadCount: 1,
              hasMore: false,
            ),
          );
          return cubit;
        },
        act: (cubit) =>
            cubit.fetchNotifications(refresh: false, tab: NotificationTab.all),
        expect: () => [
          isA<NotificationLoaded>()
              .having((s) => s.notifications.length, 'length', 2)
              .having((s) => s.notifications.map((n) => n.id).toList(), 'ids', [
                '1',
                '2',
              ]),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'fetchNotifications emits NotificationError when repository throws',
        build: () {
          when(
            () => repository.getNotifications(
              page: 1,
              pageSize: 20,
              tab: NotificationTab.all,
            ),
          ).thenThrow(Exception('Network Error'));
          return cubit;
        },
        act: (cubit) =>
            cubit.fetchNotifications(refresh: true, tab: NotificationTab.all),
        expect: () => [
          isA<NotificationLoading>(),
          isA<NotificationError>().having(
            (s) => s.message,
            'message',
            contains('Network Error'),
          ),
        ],
      );
    });
  });
}
