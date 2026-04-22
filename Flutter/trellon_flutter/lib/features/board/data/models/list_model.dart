import '../../../card/domain/entities/card_entity.dart';
import 'list_model.dart';

class ListModel {
  final String id;
  final String name;
  final int position;
  final String status;
  final String boardId;

  ListModel({
    required this.id,
    required this.name,
    required this.position,
    required this.status,
    required this.boardId,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['listUId'] ?? json['id'] ?? '',
      name: json['listName'] ?? json['name'] ?? '',
      position: json['position'] ?? 0,
      status: json['status'] ?? 'Active',
      boardId: json['boardUId'] ?? json['boardId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listUId': id,
      'listName': name,
      'position': position,
      'status': status,
      'boardUId': boardId,
    };
  }

  // Convert to domain ListEntity (with empty cards, cards loaded separately)
  ListEntityData toListEntityData() {
    return ListEntityData(
      id: id,
      name: name,
      position: position,
      status: status,
      boardId: boardId,
    );
  }
}

/// Minimal data holder for a list, cards are added separately
class ListEntityData {
  final String id;
  final String name;
  final int position;
  final String status;
  final String boardId;
  final List<CardEntity> cards;

  ListEntityData({
    required this.id,
    required this.name,
    required this.position,
    required this.status,
    required this.boardId,
    this.cards = const [],
  });

  ListEntityData copyWith({List<CardEntity>? cards}) {
    return ListEntityData(
      id: id,
      name: name,
      position: position,
      status: status,
      boardId: boardId,
      cards: cards ?? this.cards,
    );
  }
}
