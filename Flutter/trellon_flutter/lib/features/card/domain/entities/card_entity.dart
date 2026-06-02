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

class CardLabelEntity {
  final String id;
  final String title;
  final String colorCode;

  const CardLabelEntity({
    required this.id,
    required this.title,
    required this.colorCode,
  });
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
  final List<CardLabelEntity> labels;
  final List<CommentEntity> comments;
  final List<CardMemberEntity> members;

  final String? boardId;
  final String? boardName;
  final String? listName;
  final String? boardBackgroundUrl;

  const CardEntity({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.position,
    this.status = 'New',
    this.listId,
    this.backgroundUrl,
    this.boardId,
    this.boardName,
    this.listName,
    this.boardBackgroundUrl,
    this.todoItems = const [],
    this.fileUrls = const [],
    this.labels = const [],
    this.comments = const [],
    this.members = const [],
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
    List<CardLabelEntity>? labels,
    List<CommentEntity>? comments,
    List<CardMemberEntity>? members,
    String? boardId,
    String? boardName,
    String? listName,
    String? boardBackgroundUrl,
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
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      listName: listName ?? this.listName,
      boardBackgroundUrl: boardBackgroundUrl ?? this.boardBackgroundUrl,
      todoItems: todoItems ?? this.todoItems,
      fileUrls: fileUrls ?? this.fileUrls,
      labels: labels ?? this.labels,
      comments: comments ?? this.comments,
      members: members ?? this.members,
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
  final String userName;
  final String email;
  final String? avatarUrl;
  final String role;

  const CardMemberEntity({
    required this.id,
    required this.userUId,
    required this.userName,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  String get resolvedAvatarUrl {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) return avatarUrl!;
    final initials = Uri.encodeComponent(
      userName.trim().isNotEmpty ? userName.trim() : 'U',
    );
    return 'https://ui-avatars.com/api/?name=$initials&background=random&color=fff';
  }

  CardMemberEntity copyWith({String? role}) {
    return CardMemberEntity(
      id: id,
      userUId: userUId,
      userName: userName,
      email: email,
      avatarUrl: avatarUrl,
      role: role ?? this.role,
    );
  }
}
