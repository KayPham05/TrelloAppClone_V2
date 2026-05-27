import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    super.actorId,
    super.actorName,
    required super.type,
    required super.title,
    required super.message,
    super.link,
    super.workspaceId,
    super.boardId,
    super.listId,
    super.cardId,
    required super.createdAt,
    required super.isRead,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notiId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      actorId: json['actorId'],
      actorName: json['actorName'] ?? (json['actor'] != null ? json['actor']['userName'] : null),
      type: NotificationTypeEnum.fromInt(json['type'] ?? 0),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      link: json['link'],
      workspaceId: json['workspaceId'],
      boardId: json['boardId'],
      listId: json['listId'],
      cardId: json['cardId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isRead: json['read'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      type: type,
      title: title,
      message: message,
      link: link,
      workspaceId: workspaceId,
      boardId: boardId,
      listId: listId,
      cardId: cardId,
      createdAt: createdAt,
      isRead: isRead,
      readAt: readAt,
    );
  }
}

class NotificationPageModel extends NotificationPageEntity {
  const NotificationPageModel({
    required super.items,
    required super.unreadCount,
    required super.hasMore,
  });

  factory NotificationPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .map((model) => model.toEntity())
            .toList()
        : <NotificationEntity>[];

    return NotificationPageModel(
      items: items,
      unreadCount: json['unreadCount'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
