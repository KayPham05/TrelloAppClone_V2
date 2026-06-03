import 'package:dio/dio.dart';
import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:apptreolon/features/card/data/models/card_model.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

abstract class InboxRemoteDataSource {
  Future<List<CardEntity>> getInboxCards(String userUId);
  Future<CardEntity> addInboxCard(String userUId, String title, {DateTime? dueDate});
  Future<CardEntity> updateInboxCard(String cardId, String userUId, {String? title, String? description, DateTime? dueDate, String? backgroundUrl, String? status});
  Future<void> deleteInboxCard(String cardId, String userUId);
  
  // Dedicated Inbox operations
  Future<List<TodoItemEntity>> getTodoItems(String cardId);
  Future<CardEntity> addTodoItem(String cardId, String todoTitle);
  Future<CardEntity> updateTodoItem(String cardId, String todoId, bool isCompleted);
  Future<List<CommentEntity>> getComments(String cardId);
  Future<CommentEntity> addComment(String cardId, String userUId, String content);
  Future<List<FileUrlEntity>> getAttachments(String cardId);
  Future<FileUrlEntity> uploadAttachment(String cardId, String filePath, String userUId, String? description);
  Future<void> deleteAttachment(String cardId, String fileId, String userUId);
  Future<void> updateAttachmentDescription(String cardId, String fileId, String userUId, String? description);
  Future<void> moveCardToInbox(String cardId, String userUId, int position);
  Future<void> reorderInboxCards(String userUId, List<Map<String, dynamic>> items);
}

class InboxRemoteDataSourceImpl implements InboxRemoteDataSource {
  final Dio dio;

  InboxRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CardEntity>> getInboxCards(String userUId) async {
    final response = await dio.get('${ApiEndpoints.userInbox}/$userUId');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data;
      return data.map((json) => CardModel.fromJson(json).toEntity()).toList();
    }
    throw Exception("Lỗi lấy dữ liệu inbox");
  }

  @override
  Future<CardEntity> addInboxCard(String userUId, String title, {DateTime? dueDate}) async {
    final response = await dio.post(
      '${ApiEndpoints.card}/$userUId/inbox',
      data: {
        'title': title,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CardModel.fromJson(response.data).toEntity();
    }
    throw Exception("Lỗi khi thêm thẻ vào inbox");
  }

  @override
  Future<CardEntity> updateInboxCard(String cardId, String userUId, {String? title, String? description, DateTime? dueDate, String? backgroundUrl, String? status}) async {
    final response = await dio.put(
      '${ApiEndpoints.card}/inbox/$cardId?userUId=$userUId',
      data: {
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'backgroundUrl': backgroundUrl,
        'status': status,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CardModel.fromJson(response.data is Map ? response.data : {}).toEntity();
    }
    throw Exception("Lỗi khi cập nhật thẻ inbox");
  }

  @override
  Future<void> deleteInboxCard(String cardId, String userUId) async {
    final response = await dio.delete('${ApiEndpoints.card}/$cardId?userUId=$userUId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Lỗi khi xóa thẻ inbox");
    }
  }

  @override
  Future<List<TodoItemEntity>> getTodoItems(String cardId) async {
    final response = await dio.get('${ApiEndpoints.todoItem}/$cardId');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => TodoItemModel.fromJson(json).toEntity()).toList();
    }
    return [];
  }

  @override
  Future<CardEntity> addTodoItem(String cardId, String todoTitle) async {
    final response = await dio.post(
      ApiEndpoints.todoItem,
      data: {
        'cardUId': cardId,
        'content': todoTitle,
        'isCompleted': false,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CardModel.fromJson(response.data).toEntity();
    }
    throw Exception("Lỗi thêm todo inbox");
  }

  @override
  Future<CardEntity> updateTodoItem(String cardId, String todoId, bool isCompleted) async {
    final response = await dio.put(
      '${ApiEndpoints.todoItem}/$todoId',
      data: {
        'cardUId': cardId,
        'isCompleted': isCompleted,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CardModel.fromJson(response.data).toEntity();
    }
    throw Exception("Lỗi update todo inbox");
  }

  @override
  Future<List<CommentEntity>> getComments(String cardId) async {
    final response = await dio.get('${ApiEndpoints.comments}/card/$cardId');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => CommentModel.fromJson(json).toEntity()).toList();
    }
    return [];
  }

  @override
  Future<CommentEntity> addComment(String cardId, String userUId, String content) async {
    final response = await dio.post(
      ApiEndpoints.comments,
      data: {
        'cardUId': cardId,
        'userUId': userUId,
        'content': content,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommentModel.fromJson(response.data).toEntity();
    }
    throw Exception("Lỗi add comment inbox");
  }

  @override
  Future<List<FileUrlEntity>> getAttachments(String cardId) async {
    final response = await dio.get('${ApiEndpoints.card}/$cardId/attachments');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => FileUrlModel.fromJson(json).toEntity()).toList();
    }
    return [];
  }

  @override
  Future<FileUrlEntity> uploadAttachment(String cardId, String filePath, String userUId, String? description) async {
    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
      if (description != null) "description": description,
    });
    final response = await dio.post(
      '${ApiEndpoints.card}/$cardId/attachments?userUId=$userUId',
      data: formData,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return FileUrlModel.fromJson(response.data).toEntity();
    }
    throw Exception("Lỗi upload attachment inbox");
  }

  @override
  Future<void> deleteAttachment(String cardId, String fileId, String userUId) async {
    final response = await dio.delete(
      '${ApiEndpoints.card}/$cardId/attachments/$fileId?userUId=$userUId',
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Lỗi xóa attachment inbox");
    }
  }

  @override
  Future<void> updateAttachmentDescription(String cardId, String fileId, String userUId, String? description) async {
    final response = await dio.put(
      '${ApiEndpoints.card}/$cardId/attachments/$fileId?userUId=$userUId',
      data: {'description': description},
    );
    if (response.statusCode != 200) {
      throw Exception("Lỗi update attachment description inbox");
    }
  }

  @override
  Future<void> moveCardToInbox(String cardId, String userUId, int position) async {
    final response = await dio.post(
      '${ApiEndpoints.userInbox}/$userUId/move/$cardId',
      queryParameters: {'position': position},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Lỗi khi chuyển card vào inbox");
    }
  }

  @override
  Future<void> reorderInboxCards(String userUId, List<Map<String, dynamic>> items) async {
    final response = await dio.put(
      '${ApiEndpoints.userInbox}/$userUId/reorder',
      data: {'items': items},
    );
    if (response.statusCode != 200) {
      throw Exception("Lỗi khi reorder inbox");
    }
  }
}
