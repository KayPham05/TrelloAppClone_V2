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

class FileUrlEntity {
  final String id;
  final String url;
  final String fileName;
  final String? description;

  const FileUrlEntity({
    required this.id,
    required this.url,
    required this.fileName,
    this.description,
  });

  FileUrlEntity copyWith({String? id, String? url, String? fileName, String? description}) {
    return FileUrlEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      description: description ?? this.description,
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
  final String? backgroundUrl;
  final List<TodoItemEntity> todoItems;
  final List<FileUrlEntity> fileUrls;

  const CardEntity({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.position,
    this.status = 'New',
    this.listId,
    this.backgroundUrl,
    this.todoItems = const [],
    this.fileUrls = const [],
  });

  CardEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? position,
    String? status,
    String? listId,
    String? backgroundUrl,
    List<TodoItemEntity>? todoItems,
    List<FileUrlEntity>? fileUrls,
  }) {
    return CardEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      position: position ?? this.position,
      status: status ?? this.status,
      listId: listId ?? this.listId,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      todoItems: todoItems ?? this.todoItems,
      fileUrls: fileUrls ?? this.fileUrls,
    );
  }
}

class CommentEntity {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userUId;
  final String? authorName; // Mapped later from local DB or backend response

  const CommentEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userUId,
    this.authorName,
  });
}

class CardMemberEntity {
  final String id;
  final String userUId;
  final String? userName;

  const CardMemberEntity({
    required this.id,
    required this.userUId,
    this.userName,
  });
}
