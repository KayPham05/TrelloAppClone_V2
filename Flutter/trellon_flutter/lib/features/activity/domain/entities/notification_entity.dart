import 'package:equatable/equatable.dart';

enum NotificationTypeEnum {
  comment(0),
  assign(1),
  move(2),
  due(3),
  mention(4),
  workspace(5),
  board(6);

  final int value;
  const NotificationTypeEnum(this.value);

  static NotificationTypeEnum fromInt(int value) {
    return NotificationTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationTypeEnum.comment,
    );
  }
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
  final String? boardId;
  final String? cardId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.actorId,
    this.actorName,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    this.boardId,
    this.cardId,
    required this.createdAt,
    required this.isRead,
  });

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
        boardId,
        cardId,
        createdAt,
        isRead,
      ];
}
