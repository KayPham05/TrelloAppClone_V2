import '../../../../core/constants/card_status_values.dart';
import '../../domain/entities/card_entity.dart';

class CardLabelModel {
  final String id;
  final String title;
  final String colorCode;

  CardLabelModel({
    required this.id,
    required this.title,
    required this.colorCode,
  });

  factory CardLabelModel.fromJson(Map<String, dynamic> json) {
    return CardLabelModel(
      id: json['cardLabelUId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      colorCode: json['colorCode'] ?? '',
    );
  }

  CardLabelEntity toEntity() {
    return CardLabelEntity(id: id, title: title, colorCode: colorCode);
  }
}

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
      id: json['todoItemUId'] ?? json['todoUId'] ?? json['id'] ?? '',
      title: json['content'] ?? json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'todoUId': id, 'title': title, 'isCompleted': isCompleted};
  }

  TodoItemEntity toEntity() {
    return TodoItemEntity(id: id, title: title, isCompleted: isCompleted);
  }
}

class FileUrlModel {
  final String id;
  final String url;
  final String fileName;
  final String? description;

  FileUrlModel({
    required this.id,
    required this.url,
    required this.fileName,
    this.description,
  });

  factory FileUrlModel.fromJson(Map<String, dynamic> json) {
    return FileUrlModel(
      id: json['fileUId'] ?? json['attachmentUId'] ?? json['id'] ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      description: json['description'],
    );
  }

  FileUrlEntity toEntity() {
    return FileUrlEntity(
      id: id,
      url: url,
      fileName: fileName,
      description: description,
    );
  }
}

class CommentModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userUId;
  final String? authorName;
  final String? avatarUrl;
  final List<FileUrlModel> attachments;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.userUId,
    this.authorName,
    this.avatarUrl,
    this.attachments = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final attachmentsJson = json['attachments'] as List?;
    return CommentModel(
      id: json['commentUId'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      userUId: json['userUId'] ?? '',
      authorName: userJson != null ? userJson['userName'] : json['userName'],
      avatarUrl:
          json['avatarUrl'] ??
          (userJson != null ? userJson['avatarUrl'] : null),
      attachments: attachmentsJson != null
          ? attachmentsJson.map((item) => FileUrlModel.fromJson(item)).toList()
          : const [],
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userUId: userUId,
      authorName: authorName,
      avatarUrl: avatarUrl,
      attachments: attachments.map((item) => item.toEntity()).toList(),
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
  final String? backgroundUrl;
  final List<TodoItemModel> todoItems;
  final List<FileUrlModel> fileUrls;
  final List<CardLabelEntity> labels;
  final List<CommentEntity> comments;
  final List<CardMemberEntity> members;

  final String? boardId;
  final String? boardName;
  final String? listName;
  final String? boardBackgroundUrl;

  CardModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.position,
    this.status = CardStatusValues.toDo,
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

  factory CardModel.fromJson(Map<String, dynamic> json) {
    var todosFromJson = json['todos'] ?? json['todoItems'] as List?;
    List<TodoItemModel> todoList = todosFromJson != null
        ? (todosFromJson as List).map((i) => TodoItemModel.fromJson(i)).toList()
        : [];

    var filesFromJson = json['fileUrls'] as List?;
    List<FileUrlModel> fileList = filesFromJson != null
        ? filesFromJson.map((i) => FileUrlModel.fromJson(i)).toList()
        : [];

    var commentsFromJson = json['comments'] as List?;
    List<CommentEntity> commentList = commentsFromJson != null
        ? commentsFromJson
              .map((json) => CommentModel.fromJson(json).toEntity())
              .toList()
        : [];

    var membersFromJson = (json['members'] ?? json['cardMembers']) as List?;
    List<CardMemberEntity> memberList = membersFromJson != null
        ? membersFromJson
              .map(
                (json) => CardMemberEntity(
                  id: json['id'] ?? json['cardMemberUId'] ?? '',
                  userUId: json['userUId'] ?? '',
                  userName:
                      json['userName'] ??
                      json['fullName'] ??
                      (json['user'] != null
                          ? (json['user']['userName'] ??
                                json['user']['name'] ??
                                'Unknown')
                          : 'Unknown'),
                  email:
                      json['email'] ??
                      (json['user'] != null ? json['user']['email'] : ''),
                  avatarUrl:
                      json['avatarUrl'] ??
                      json['avatar'] ??
                      (json['user'] != null
                          ? (json['user']['avatarUrl'] ??
                                json['user']['avatar'])
                          : null),
                  role: json['role'] ?? 'Observer',
                ),
              )
              .toList()
        : [];

    return CardModel(
      id: json['cardUId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
      position: json['position'] ?? 0,
      status: CardStatusValues.normalize(json['status']),
      listId: json['listUId'] ?? json['listId'],
      backgroundUrl: json['backgroundUrl'],
      boardId: json['boardUId'] ?? json['boardId'],
      boardName: json['boardName'],
      listName: json['listName'] ?? json['listTitle'],
      boardBackgroundUrl: json['boardBackgroundUrl'] ?? json['boardUrl'],
      todoItems: todoList,
      fileUrls: fileList,
      comments: commentList,
      members: memberList,
      labels:
          (json['cardLabels'] as List?)
              ?.map((e) => CardLabelModel.fromJson(e).toEntity())
              .toList() ??
          [],
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
      backgroundUrl: backgroundUrl,
      boardId: boardId,
      boardName: boardName,
      listName: listName,
      boardBackgroundUrl: boardBackgroundUrl,
      todoItems: todoItems.map((e) => e.toEntity()).toList(),
      fileUrls: fileUrls.map((e) => e.toEntity()).toList(),
      labels: labels,
      comments: comments,
      members: members,
    );
  }
}
