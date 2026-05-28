import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final bool hasReachedMax;
  final int unreadCount;
  final NotificationTab tab;

  const NotificationLoaded({
    required this.notifications,
    this.hasReachedMax = false,
    this.unreadCount = 0,
    this.tab = NotificationTab.all,
  });

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    bool? hasReachedMax,
    int? unreadCount,
    NotificationTab? tab,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
      tab: tab ?? this.tab,
    );
  }

  @override
  List<Object?> get props => [notifications, hasReachedMax, unreadCount, tab];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
