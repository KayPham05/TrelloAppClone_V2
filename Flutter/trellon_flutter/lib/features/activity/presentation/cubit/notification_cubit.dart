import 'package:flutter_bloc/flutter_bloc.dart';
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

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
    required this.markAllReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(NotificationInitial());

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isFetching) return;

    if (refresh) {
      _currentPage = 1;
      emit(NotificationLoading());
    } else {
      if (state is NotificationLoaded && (state as NotificationLoaded).hasReachedMax) {
        return;
      }
    }

    _isFetching = true;

    try {
      final newNotifications = await getNotificationsUseCase.call(page: _currentPage, pageSize: _pageSize);
      
      _isFetching = false;
      
      if (refresh) {
        emit(NotificationLoaded(
          notifications: newNotifications,
          hasReachedMax: newNotifications.length < _pageSize,
        ));
      } else {
        final currentState = state;
        if (currentState is NotificationLoaded) {
          emit(currentState.copyWith(
            notifications: List.of(currentState.notifications)..addAll(newNotifications),
            hasReachedMax: newNotifications.length < _pageSize,
          ));
        } else {
          emit(NotificationLoaded(
            notifications: newNotifications,
            hasReachedMax: newNotifications.length < _pageSize,
          ));
        }
      }

      if (newNotifications.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      _isFetching = false;
      if (refresh) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> markAsRead(String notiId) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        final success = await markAsReadUseCase.call(notiId: notiId);
        if (success) {
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == notiId) {
              return NotificationEntity(
                id: n.id,
                recipientId: n.recipientId,
                actorId: n.actorId,
                actorName: n.actorName,
                type: n.type,
                title: n.title,
                message: n.message,
                link: n.link,
                boardId: n.boardId,
                cardId: n.cardId,
                createdAt: n.createdAt,
                isRead: true,
              );
            }
            return n;
          }).toList();
          emit(currentState.copyWith(notifications: updatedNotifications));
        }
      } catch (e) {
        // Log error silently or show a snackbar (but state remains the same for UI)
      }
    }
  }

  Future<bool> markAllAsRead() async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        final updatedCount = await markAllReadUseCase.call();
        if (updatedCount >= 0) {
          final updatedNotifications = currentState.notifications.map((n) {
            return NotificationEntity(
              id: n.id,
              recipientId: n.recipientId,
              actorId: n.actorId,
              actorName: n.actorName,
              type: n.type,
              title: n.title,
              message: n.message,
              link: n.link,
              boardId: n.boardId,
              cardId: n.cardId,
              createdAt: n.createdAt,
              isRead: true,
            );
          }).toList();
          emit(currentState.copyWith(notifications: updatedNotifications));
          return true;
        }
      } catch (e) {
        // Log error
      }
    }
    return false;
  }

  int get unreadCount {
    final s = state;
    if (s is NotificationLoaded) {
      return s.notifications.where((n) => !n.isRead).length;
    }
    return 0;
  }

  void reset() {
    _currentPage = 1;
    emit(NotificationInitial());
  }

  (NotificationEntity, int)? removeNotificationLocally(String notiId) {
    final s = state;
    if (s is! NotificationLoaded) return null;
    final idx = s.notifications.indexWhere((n) => n.id == notiId);
    if (idx == -1) return null;
    final entity = s.notifications[idx];
    final newList = List<NotificationEntity>.from(s.notifications)..removeAt(idx);
    emit(s.copyWith(notifications: newList));
    return (entity, idx);
  }

  void undoDeleteNotification(NotificationEntity entity, int index) {
    final s = state;
    if (s is! NotificationLoaded) return;
    final newList = List<NotificationEntity>.from(s.notifications)
      ..insert(index.clamp(0, s.notifications.length), entity);
    emit(s.copyWith(notifications: newList));
  }

  Future<bool> confirmDeleteNotification(String notiId, NotificationEntity entity, int index) async {
    try {
      final success = await deleteNotificationUseCase.call(notiId: notiId);
      if (!success) {
        undoDeleteNotification(entity, index);
      }
      return success;
    } catch (e) {
      undoDeleteNotification(entity, index);
      return false;
    }
  }
}
