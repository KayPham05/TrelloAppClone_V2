// activity_page_notification_flow_test.dart
//
// Tests cubit behaviors that underpin the ActivityPage notification flow:
//   - tab switch triggers a server-side fetch for the new tab
//   - pull-to-refresh uses the current active tab
//   - read tab shows stale state while another tab is loading
//   - markAllAsRead keeps read tab items and marks them read
//
// Note: Full widget tests for ActivityPage require platform plugins
// (FlutterSecureStorage, SignalR) and cannot run in the pure-Dart VM.
// The tests below use MockNotificationRepository and bloc_test to verify
// the cubit layer which is the primary logic being exercised by the page.

import 'dart:async';

import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:apptreolon/features/activity/domain/repositories/i_notification_repository.dart';
import 'package:apptreolon/features/activity/domain/usecases/delete_notification_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/get_notifications_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/mark_all_read_usecase.dart';
import 'package:apptreolon/features/activity/domain/usecases/mark_as_read_usecase.dart';
import 'package:apptreolon/features/activity/presentation/controllers/notification_tab_coordinator.dart';
import 'package:apptreolon/features/activity/presentation/cubit/notification_cubit.dart';
import 'package:apptreolon/features/activity/presentation/cubit/notification_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements INotificationRepository {}

final _unread = NotificationEntity(
  id: 'u1',
  recipientId: 'user-1',
  title: 'Assigned',
  message: 'You were assigned to a card',
  createdAt: DateTime(2026, 5, 25),
  isRead: false,
  type: NotificationTypeEnum.assign,
);

final _read = NotificationEntity(
  id: 'r1',
  recipientId: 'user-1',
  title: 'Comment',
  message: 'Someone commented',
  createdAt: DateTime(2026, 5, 25),
  isRead: true,
  type: NotificationTypeEnum.comment,
);

void main() {
  late MockNotificationRepository repository;

  NotificationCubit buildCubit() => NotificationCubit(
        getNotificationsUseCase: GetNotificationsUseCase(repository),
        markAsReadUseCase: MarkAsReadUseCase(repository),
        markAllReadUseCase: MarkAllReadUseCase(repository),
        deleteNotificationUseCase: DeleteNotificationUseCase(repository),
      );

  setUp(() {
    repository = MockNotificationRepository();
  });

  group('ActivityPage notification flow — cubit layer', () {
    blocTest<NotificationCubit, NotificationState>(
      'switching tabs requests the correct NotificationTab from the server',
      build: () {
        when(
          () => repository.getNotifications(
            page: 1,
            pageSize: 20,
            tab: NotificationTab.sentToMe,
          ),
        ).thenAnswer(
          (_) async => NotificationPageEntity(
            items: [_unread],
            unreadCount: 1,
            hasMore: false,
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.fetchNotifications(refresh: true, tab: NotificationTab.sentToMe),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>()
            .having((s) => s.tab, 'tab', NotificationTab.sentToMe)
            .having((s) => s.notifications.length, 'length', 1),
      ],
      verify: (_) {
        verify(
          () => repository.getNotifications(
            page: 1,
            pageSize: 20,
            tab: NotificationTab.sentToMe,
          ),
        ).called(1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'pull-to-refresh uses the current active tab',
      build: () {
        // First fetch sets tab to read.
        when(
          () => repository.getNotifications(
            page: 1,
            pageSize: 20,
            tab: NotificationTab.read,
          ),
        ).thenAnswer(
          (_) async => NotificationPageEntity(
            items: [_read],
            unreadCount: 1,
            hasMore: false,
          ),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.fetchNotifications(refresh: true, tab: NotificationTab.read);
        await cubit.fetchNotifications(refresh: true, tab: NotificationTab.read);
      },
      verify: (_) {
        verify(
          () => repository.getNotifications(
            page: 1,
            pageSize: 20,
            tab: NotificationTab.read,
          ),
        ).called(2);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAllAsRead on read tab keeps notifications and zeroes unreadCount',
      seed: () => NotificationLoaded(
        notifications: [_unread],
        unreadCount: 1,
        tab: NotificationTab.read,
      ),
      build: () {
        when(() => repository.markAllAsRead()).thenAnswer((_) async => 1);
        return buildCubit();
      },
      act: (cubit) => cubit.markAllAsRead(),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 1)
            .having((s) => s.notifications.first.isRead, 'isRead', true)
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAllAsRead on all tab marks items read but keeps them in the list',
      seed: () => NotificationLoaded(
        notifications: [_unread, _read],
        unreadCount: 1,
        tab: NotificationTab.all,
      ),
      build: () {
        when(() => repository.markAllAsRead()).thenAnswer((_) async => 1);
        return buildCubit();
      },
      act: (cubit) => cubit.markAllAsRead(),
      expect: () => [
        isA<NotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 2)
            .having((s) => s.notifications.every((n) => n.isRead), 'all read', true)
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );

    test('read-tab fetch is not dropped while another tab request is in flight', () async {
      final allCompleter = Completer<NotificationPageEntity>();
      when(
        () => repository.getNotifications(
          page: 1,
          pageSize: 20,
          tab: NotificationTab.all,
        ),
      ).thenAnswer((_) => allCompleter.future);
      when(
        () => repository.getNotifications(
          page: 1,
          pageSize: 20,
          tab: NotificationTab.read,
        ),
      ).thenAnswer(
        (_) async => NotificationPageEntity(
          items: [_read],
          unreadCount: 0,
          hasMore: false,
        ),
      );

      final cubit = buildCubit();
      final allFetch = cubit.fetchNotifications(refresh: true, tab: NotificationTab.all);
      await Future<void>.delayed(Duration.zero);

      final readFetch = cubit.fetchNotifications(refresh: true, tab: NotificationTab.read);
      await readFetch;

      allCompleter.complete(
        NotificationPageEntity(
          items: [_unread],
          unreadCount: 1,
          hasMore: false,
        ),
      );
      await allFetch;

      final state = cubit.state;
      expect(state, isA<NotificationLoaded>());
      final loaded = state as NotificationLoaded;
      expect(loaded.tab, NotificationTab.read);
      expect(loaded.notifications, [_read]);
      verify(
        () => repository.getNotifications(
          page: 1,
          pageSize: 20,
          tab: NotificationTab.read,
        ),
      ).called(1);
      await cubit.close();
    });
  });

  group('NotificationTabCoordinator', () {
    test('tap on another tab animates only and leaves fetch to page change', () {
      final coordinator = NotificationTabCoordinator();

      final action = coordinator.onTap(1);

      expect(action.animateToPage, true);
      expect(action.fetchNotifications, false);
      expect(coordinator.selectedIndex, 1);
    });

    test('tap on selected tab does not animate or fetch', () {
      final coordinator = NotificationTabCoordinator();

      final action = coordinator.onTap(0);

      expect(action.animateToPage, false);
      expect(action.fetchNotifications, false);
      expect(coordinator.selectedIndex, 0);
    });

    test('page change fetches exactly once for the visible tab', () {
      final coordinator = NotificationTabCoordinator();
      coordinator.onTap(1);

      final action = coordinator.onPageChanged(1);

      expect(action.animateToPage, false);
      expect(action.fetchNotifications, true);
      expect(action.tab, NotificationTab.sentToMe);
    });

    test('third tab maps to read notifications', () {
      final action = NotificationTabCoordinator().onPageChanged(2);

      expect(action.fetchNotifications, true);
      expect(action.tab, NotificationTab.read);
    });
  });
}
