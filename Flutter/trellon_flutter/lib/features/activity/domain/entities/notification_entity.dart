import 'package:equatable/equatable.dart';

enum NotificationTypeEnum {
  comment(0),
  assign(1),
  move(2),
  due(3),
  mention(4),
  workspace(5),
  board(6),
  cardUnassigned(7),
  boardMemberAdded(8),
  boardMemberRemoved(9),
  boardRoleChanged(10),
  workspaceMemberAdded(11),
  workspaceMemberRemoved(12),
  workspaceRoleChanged(13),
  dueDateChanged(14),
  dueDateReminder(15);

  final int value;
  const NotificationTypeEnum(this.value);

  static NotificationTypeEnum fromInt(int value) {
    return NotificationTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationTypeEnum.comment,
    );
  }
}

enum NotificationTab {
  all('all'),
  sentToMe('sentToMe'),
  read('read');

  final String apiValue;
  const NotificationTab(this.apiValue);
}

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final String? actorId;
  final String? actorName;
  final NotificationTypeEnum type;
  final String title;
  final String message;
  final String? link;
  final String? workspaceId;
  final String? boardId;
  final String? listId;
  final String? cardId;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.actorId,
    this.actorName,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    this.workspaceId,
    this.boardId,
    this.listId,
    this.cardId,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    String? actorId,
    String? actorName,
    NotificationTypeEnum? type,
    String? title,
    String? message,
    String? link,
    String? workspaceId,
    String? boardId,
    String? listId,
    String? cardId,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      link: link ?? this.link,
      workspaceId: workspaceId ?? this.workspaceId,
      boardId: boardId ?? this.boardId,
      listId: listId ?? this.listId,
      cardId: cardId ?? this.cardId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipientId,
        actorId,
        actorName,
        type,
        title,
        message,
        link,
        workspaceId,
        boardId,
        listId,
        cardId,
        createdAt,
        isRead,
        readAt,
      ];
}

class NotificationPageEntity extends Equatable {
  final List<NotificationEntity> items;
  final int unreadCount;
  final bool hasMore;

  const NotificationPageEntity({
    required this.items,
    required this.unreadCount,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, unreadCount, hasMore];
}
