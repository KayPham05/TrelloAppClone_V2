class TodoItemEntity {
  final String id;
  final String title;
  final bool isCompleted;

  const TodoItemEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  TodoItemEntity copyWith({String? title, bool? isCompleted}) {
    return TodoItemEntity(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class CardEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int position;
  final String status;
  final String? listId;
  final List<TodoItemEntity> todoItems;

  const CardEntity({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.position,
    this.status = 'New',
    this.listId,
    this.todoItems = const [],
  });

  CardEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? position,
    String? status,
    String? listId,
    List<TodoItemEntity>? todoItems,
  }) {
    return CardEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      position: position ?? this.position,
      status: status ?? this.status,
      listId: listId ?? this.listId,
      todoItems: todoItems ?? this.todoItems,
    );
  }
}
