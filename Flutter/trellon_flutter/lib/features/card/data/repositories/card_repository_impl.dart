import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/i_card_repository.dart';
import '../models/card_model.dart';
import '../models/update_list_request_model.dart';

class CardRepositoryImpl implements ICardRepository {
  final Dio dio;

  CardRepositoryImpl({required this.dio});

  @override
  Future<CardEntity> addCard({required String listId, required String title, required int position}) async {
    try {
      final response = await dio.post(ApiEndpoints.card, data: {
        'listUId': listId,
        'title': title,
        'position': position,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi thêm thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateCard({required String cardId, required String title, String? description, DateTime? dueDate}) async {
    try {
      final data = {
        'title': title,
      };
      if (description != null) data['description'] = description;
      if (dueDate != null) data['dueDate'] = dueDate.toIso8601String();

      final response = await dio.put('${ApiEndpoints.card}/$cardId', data: data);
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi cập nhật thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> deleteCard({required String cardId}) async {
    try {
      final response = await dio.delete('${ApiEndpoints.card}/$cardId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lỗi khi xóa thẻ');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<String> getCardDescription({required String cardId}) async {
    try {
      final response = await dio.get('${ApiEndpoints.card}/$cardId/description');
      if (response.statusCode == 200) {
        return response.data['description'] ?? '';
      }
      throw Exception('Lỗi khi lấy mô tả thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateListUId({required String cardId, required String newListId, required int newPosition}) async {
    try {
      final request = UpdateListRequestModel(listUId: newListId, position: newPosition);
      final response = await dio.put('${ApiEndpoints.card}/$cardId/list', data: request.toJson());
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi di chuyển thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateStatus({required String cardId, required String newStatus}) async {
    try {
      final response = await dio.put('${ApiEndpoints.card}/$cardId/status', data: {'status': newStatus});
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi cập nhật trạng thái');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> addTodoItem({required String cardId, required String todoTitle}) async {
    try {
      final response = await dio.post('${ApiEndpoints.card}/$cardId/todos', data: {'title': todoTitle});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi thêm Todo');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateTodoItem({required String cardId, required String todoId, required bool isCompleted}) async {
    try {
      final response = await dio.put('${ApiEndpoints.card}/$cardId/todos/$todoId', data: {'isCompleted': isCompleted});
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi cập nhật Todo');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateDueDate({required String cardId, required DateTime dueDate}) async {
    try {
      final response = await dio.put('${ApiEndpoints.card}/$cardId/duedate', data: {'dueDate': dueDate.toIso8601String()});
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi cập nhật ngày hết hạn');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<List<CommentEntity>> getComments({required String cardId}) async {
    try {
      final response = await dio.get('${ApiEndpoints.comments}/card/$cardId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          return CommentEntity(
            id: json['commentUId'] ?? '',
            content: json['content'] ?? '',
            createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
            userUId: json['userUId'] ?? '',
            authorName: json['authorName'], // Assuming backend might return this
          );
        }).toList();
      }
      throw Exception('Lỗi khi lấy bình luận');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CommentEntity> addComment({required String cardId, required String content, required String userUId}) async {
    try {
      final response = await dio.post(ApiEndpoints.comments, data: {
        'cardUId': cardId,
        'content': content,
        'userUId': userUId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data;
        return CommentEntity(
          id: json['commentUId'] ?? '',
          content: json['content'] ?? '',
          createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
          userUId: json['userUId'] ?? '',
        );
      }
      throw Exception('Lỗi khi thêm bình luận');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<List<CardMemberEntity>> getCardMembers({required String cardId}) async {
    try {
      final response = await dio.get('${ApiEndpoints.cardMember}/$cardId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          return CardMemberEntity(
            id: json['id'] ?? json['cardMemberUId'] ?? '',
            userUId: json['userUId'] ?? '',
            userName: json['userName'] ?? json['fullName'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return [];
      throw Exception('Lỗi kết nối server khi lấy thành viên: $e');
    }
  }

  @override
  Future<List<TodoItemEntity>> getTodoItems({required String cardId}) async {
    try {
      final response = await dio.get('${ApiEndpoints.todoItem}/$cardId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TodoItemModel.fromJson(json).toEntity()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi kết nối server khi lấy danh sách việc: $e');
    }
  }
}
