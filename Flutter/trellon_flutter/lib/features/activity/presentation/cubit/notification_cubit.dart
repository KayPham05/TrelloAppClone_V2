import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_read_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllReadUseCase markAllReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isFetching = false;
  int _activeFetchId = 0;
  NotificationTab _currentTab = NotificationTab.all;

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
    required this.markAllReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(NotificationInitial());

  Future<void> fetchNotifications({
    bool refresh = false,
    NotificationTab tab = NotificationTab.all,
  }) async {
    final tabChanged = tab != _currentTab;
    final resetList = refresh || tabChanged;
    if (_isFetching && !resetList) return;

    if (!resetList &&
        state is NotificationLoaded &&
        (state as NotificationLoaded).hasReachedMax) {
      return;
    }

    final fetchId = ++_activeFetchId;
    final fetchPage = resetList ? 1 : _currentPage;
    final fetchTab = tab;

    if (resetList) {
      _currentPage = 1;
      _currentTab = fetchTab;
      emit(NotificationLoading());
    }

    _isFetching = true;

    try {
      final page = await getNotificationsUseCase.call(
        page: fetchPage,
        pageSize: _pageSize,
        tab: fetchTab,
      );

      if (fetchId != _activeFetchId || fetchTab != _currentTab) return;

      final currentState = state;
      final notifications = currentState is NotificationLoaded && !resetList
          ? _dedupeById([...currentState.notifications, ...page.items])
          : page.items;

      emit(
        NotificationLoaded(
          notifications: notifications,
          hasReachedMax: !page.hasMore,
          unreadCount: page.unreadCount,
          tab: fetchTab,
        ),
      );

      if (page.items.isNotEmpty) {
        _currentPage = fetchPage + 1;
      }
    } catch (e) {
      if (fetchId != _activeFetchId || fetchTab != _currentTab) return;
      if (resetList || state is! NotificationLoaded) {
        emit(NotificationError(e.toString()));
      }
    } finally {
      if (fetchId == _activeFetchId) {
        _isFetching = false;
      }
    }
  }

  Future<void> markAsRead(String notiId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    final notificationIndex = currentState.notifications.indexWhere(
      (n) => n.id == notiId,
    );
    if (notificationIndex == -1) return;
    final notification = currentState.notifications[notificationIndex];
    if (notification.isRead) return;

    try {
      final success = await markAsReadUseCase.call(notiId: notiId);
      if (!success) return;

      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == notiId) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      final visibleNotifications = currentState.tab == NotificationTab.sentToMe
          ? updatedNotifications.where((n) => n.id != notiId).toList()
          : updatedNotifications;

      emit(
        currentState.copyWith(
          notifications: visibleNotifications,
          unreadCount: _decrementUnread(currentState.unreadCount),
        ),
      );
    } catch (_) {
      // Keep current UI state when the server update fails.
    }
  }

  Future<bool> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return false;

    try {
      await markAllReadUseCase.call();
      final updatedNotifications = currentState.tab == NotificationTab.sentToMe
          ? <NotificationEntity>[]
          : currentState.notifications
                .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
                .toList();
      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  int get unreadCount {
    final s = state;
    if (s is NotificationLoaded) {
      return s.unreadCount;
    }
    return 0;
  }

  void applyRealtimeNotification(NotificationEntity notification) {
    final s = state;
    if (s is! NotificationLoaded) return;
    if (s.notifications.any((n) => n.id == notification.id)) return;

    final unreadCount = notification.isRead ? s.unreadCount : s.unreadCount + 1;
    final shouldDisplay = _matchesTab(notification, s.tab);
    if (!shouldDisplay && unreadCount == s.unreadCount) return;
    final notifications = shouldDisplay
        ? [notification, ...s.notifications]
        : s.notifications;

    emit(s.copyWith(notifications: notifications, unreadCount: unreadCount));
  }

  void applyUnreadCount(int unreadCount) {
    final s = state;
    if (s is NotificationLoaded) {
      emit(s.copyWith(unreadCount: unreadCount));
    }
  }

  void applyNotificationRead(String notiId) {
    final s = state;
    if (s is! NotificationLoaded) return;

    final existingIndex = s.notifications.indexWhere((n) => n.id == notiId);
    if (existingIndex == -1) return;
    final existing = s.notifications[existingIndex];
    final unreadCount = existing.isRead
        ? s.unreadCount
        : _decrementUnread(s.unreadCount);
    if (s.tab == NotificationTab.sentToMe) {
      emit(
        s.copyWith(
          notifications: s.notifications.where((n) => n.id != notiId).toList(),
          unreadCount: unreadCount,
        ),
      );
      return;
    }

    final notifications = s.notifications
        .map(
          (n) => n.id == notiId
              ? n.copyWith(isRead: true, readAt: DateTime.now())
              : n,
        )
        .toList();
    emit(s.copyWith(notifications: notifications, unreadCount: unreadCount));
  }

  void applyNotificationDeleted(String notiId) {
    final s = state;
    if (s is! NotificationLoaded) return;
    emit(
      s.copyWith(
        notifications: s.notifications.where((n) => n.id != notiId).toList(),
      ),
    );
  }

  void applyNotificationReadAll() {
    final s = state;
    if (s is! NotificationLoaded) return;

    final notifications = s.tab == NotificationTab.sentToMe
        ? <NotificationEntity>[]
        : s.notifications
              .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
              .toList();

    emit(s.copyWith(notifications: notifications, unreadCount: 0));
  }

  void reset() {
    _currentPage = 1;
    _activeFetchId++;
    _isFetching = false;
    _currentTab = NotificationTab.all;
    emit(NotificationInitial());
  }

  Future<void> applyRealtimeProfileUpdated(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    if (payload['userName'] != null)
      await prefs.setString('user_name', payload['userName']);
    if (payload['avatarUrl'] != null)
      await prefs.setString('user_avatar', payload['avatarUrl']);
    // Bio is not typically in shared_prefs but could be added if needed

    // We don't necessarily need to emit a new state for NotificationCubit
    // unless we want to signal subscribers that profile changed.
  }

  Future<void> applyAccountLocked() async {
    // 1. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.setBool('isLogged', false);

    // 2. Clear SecureStorage
    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();

    // 3. Clear Cookies
    if (serviceLocator.isRegistered<CookieJar>()) {
      await serviceLocator<CookieJar>().deleteAll();
    }

    // 4. Signal Logout to UI
    final s = state;
    if (s is NotificationLoaded) {
      emit(s.copyWith(isLogoutRequested: true));
    } else {
      emit(NotificationLoaded(notifications: [], isLogoutRequested: true));
    }
  }

  (NotificationEntity, int)? removeNotificationLocally(String notiId) {
    final s = state;
    if (s is! NotificationLoaded) return null;
    final idx = s.notifications.indexWhere((n) => n.id == notiId);
    if (idx == -1) return null;
    final entity = s.notifications[idx];
    final newList = List<NotificationEntity>.from(s.notifications)
      ..removeAt(idx);
    emit(
      s.copyWith(
        notifications: newList,
        unreadCount: entity.isRead
            ? s.unreadCount
            : _decrementUnread(s.unreadCount),
      ),
    );
    return (entity, idx);
  }

  void undoDeleteNotification(NotificationEntity entity, int index) {
    final s = state;
    if (s is! NotificationLoaded) return;
    final newList = List<NotificationEntity>.from(s.notifications)
      ..insert(index.clamp(0, s.notifications.length), entity);
    emit(
      s.copyWith(
        notifications: newList,
        unreadCount: entity.isRead ? s.unreadCount : s.unreadCount + 1,
      ),
    );
  }

  Future<bool> confirmDeleteNotification(
    String notiId,
    NotificationEntity entity,
    int index,
  ) async {
    try {
      final success = await deleteNotificationUseCase.call(notiId: notiId);
      if (!success) {
        undoDeleteNotification(entity, index);
      }
      return success;
    } catch (_) {
      undoDeleteNotification(entity, index);
      return false;
    }
  }

  bool _matchesTab(NotificationEntity notification, NotificationTab tab) {
    return switch (tab) {
      NotificationTab.all => true,
      NotificationTab.read => notification.isRead,
      NotificationTab.sentToMe =>
        !notification.isRead && _isSentToMe(notification.type),
    };
  }

  bool _isSentToMe(NotificationTypeEnum type) {
    return {
      NotificationTypeEnum.assign,
      NotificationTypeEnum.cardUnassigned,
      NotificationTypeEnum.mention,
      NotificationTypeEnum.boardMemberAdded,
      NotificationTypeEnum.boardMemberRemoved,
      NotificationTypeEnum.boardRoleChanged,
      NotificationTypeEnum.workspaceMemberAdded,
      NotificationTypeEnum.workspaceMemberRemoved,
      NotificationTypeEnum.workspaceRoleChanged,
      NotificationTypeEnum.dueDateChanged,
      NotificationTypeEnum.dueDateReminder,
    }.contains(type);
  }

  List<NotificationEntity> _dedupeById(List<NotificationEntity> notifications) {
    final seen = <String>{};
    final result = <NotificationEntity>[];
    for (final notification in notifications) {
      if (seen.add(notification.id)) {
        result.add(notification);
      }
    }
    return result;
  }

  int _decrementUnread(int current) => current > 0 ? current - 1 : 0;
}
