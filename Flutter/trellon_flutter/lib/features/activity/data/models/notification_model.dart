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
    super.boardId,
    super.cardId,
    required super.createdAt,
    required super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notiId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      actorId: json['actorId'],
      actorName: json['actor'] != null ? json['actor']['userName'] : null,
      type: NotificationTypeEnum.fromInt(json['type'] ?? 0),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      link: json['link'],
      boardId: json['boardId'],
      cardId: json['cardId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isRead: json['read'] ?? false,
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
      boardId: boardId,
      cardId: cardId,
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}
