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
      id: json['todoItemUId'] ?? json['todoUId'] ?? json['id'] ?? '',
      title: json['content'] ?? json['title'] ?? '',
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
      id: json['fileUId'] ?? json['id'] ?? '',
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

  CardModel({
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

  factory CardModel.fromJson(Map<String, dynamic> json) {
    var todosFromJson = json['todos'] ?? json['todoItems'] as List?;
    List<TodoItemModel> todoList = todosFromJson != null
        ? (todosFromJson as List).map((i) => TodoItemModel.fromJson(i)).toList()
        : [];

    var filesFromJson = json['fileUrls'] as List?;
    List<FileUrlModel> fileList = filesFromJson != null
        ? filesFromJson.map((i) => FileUrlModel.fromJson(i)).toList()
        : [];

    return CardModel(
      id: json['cardUId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      position: json['position'] ?? 0,
      status: json['status'] ?? 'New',
      listId: json['listUId'] ?? json['listId'],
      backgroundUrl: json['backgroundUrl'],
      todoItems: todoList,
      fileUrls: fileList,
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
      todoItems: todoItems.map((e) => e.toEntity()).toList(),
      fileUrls: fileUrls.map((e) => e.toEntity()).toList(),
    );
  }
}
