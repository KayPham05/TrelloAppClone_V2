import '../../domain/entities/card_entity.dart';

class TodoItemModel {
  final String id;
  final String title;
  final bool isCompleted;

  TodoItemModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    return TodoItemModel(
      id: json['todoUId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todoUId': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  TodoItemEntity toEntity() {
    return TodoItemEntity(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }
}

class CardModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int position;
  final String status;
  final String? listId;
  final List<TodoItemModel> todoItems;

  CardModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.position,
    this.status = 'New',
    this.listId,
    this.todoItems = const [],
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    var todosFromJson = json['todos'] as List?;
    List<TodoItemModel> todoList = todosFromJson != null
        ? todosFromJson.map((i) => TodoItemModel.fromJson(i)).toList()
        : [];

    return CardModel(
      id: json['cardUId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      position: json['position'] ?? 0,
      status: json['status'] ?? 'New',
      listId: json['listUId'] ?? json['listId'],
      todoItems: todoList,
    );
  }

  CardEntity toEntity() {
    return CardEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      position: position,
      status: status,
      listId: listId,
      todoItems: todoItems.map((e) => e.toEntity()).toList(),
    );
  }
}
