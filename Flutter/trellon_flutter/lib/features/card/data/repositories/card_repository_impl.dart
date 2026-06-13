import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/card_status_values.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/i_card_repository.dart';
import '../models/card_model.dart';
import '../models/update_list_request_model.dart';

class CardRepositoryImpl implements ICardRepository {
  final Dio dio;

  CardRepositoryImpl({required this.dio});

  @override
  Future<CardEntity> getCard(String cardId) async {
    try {
      final response = await dio.get('${ApiEndpoints.card}/$cardId');
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Card không tồn tại');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin card: $e');
    }
  }

  @override
  Future<CardEntity> addCard({
    required String listId,
    required String title,
    required int position,
    required String userUId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.card,
        data: {
          'listUId': listId,
          'title': title,
          'position': position,
          'userUId': userUId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi thêm thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateCard({
    required String cardId,
    required String title,
    required String userUId,
    String? description,
    DateTime? dueDate,
    String? backgroundUrl,
    int? position,
    String? listId,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'backgroundUrl': backgroundUrl,
        'position': position ?? 0,
        'listUId': listId,
      };

      final response = await dio.put(
        '${ApiEndpoints.card}/$cardId?userUId=$userUId',
        data: data,
      );
      if (response.statusCode == 200) {
        return const CardEntity(
          id: '',
          title: '',
          position: 0,
        ); // dummy response
      }
      throw Exception('Lỗi khi cập nhật thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> deleteCard({
    required String cardId,
    required String userUId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.card}/$cardId?userUId=$userUId',
      );
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
      final response = await dio.get(
        '${ApiEndpoints.card}/$cardId/description',
      );
      if (response.statusCode == 200) {
        return response.data['description'] ?? '';
      }
      throw Exception('Lỗi khi lấy mô tả thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateListUId({
    required String cardId,
    required String newListId,
    required String userUId,
  }) async {
    try {
      final request = UpdateListRequestModel(
        listUId: newListId,
        userUId: userUId,
      );
      final response = await dio.put(
        '${ApiEndpoints.card}/$cardId/update-list',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi di chuyển thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateStatus({
    required String cardId,
    required String newStatus,
    required String userUId,
  }) async {
    try {
      final normalizedStatus = CardStatusValues.normalize(newStatus);
      final response = await dio.put(
        '${ApiEndpoints.card}/$cardId/update-status?newStatus=$normalizedStatus&userUId=$userUId',
      );
      if (response.statusCode == 200) {
        return const CardEntity(id: '', title: '', position: 0);
      }
      throw Exception('Lỗi khi cập nhật trạng thái');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> addTodoItem({
    required String cardId,
    required String todoTitle,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.todoItem}/add',
        data: {'cardUId': cardId, 'content': todoTitle},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const CardEntity(
          id: '',
          title: '',
          position: 0,
        ); // Dummy, caller handles refetch
      }
      throw Exception('Lỗi khi thêm Todo');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateTodoItem({
    required String cardId,
    required String todoId,
    required bool isCompleted,
  }) async {
    try {
      final response = await dio.put(
        '${ApiEndpoints.todoItem}/$todoId/update-status?status=${isCompleted ? "completed" : "active"}',
      );
      if (response.statusCode == 200) {
        return const CardEntity(
          id: '',
          title: '',
          position: 0,
        ); // Dummy, caller handles refetch
      }
      throw Exception('Lỗi khi cập nhật Todo');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardEntity> updateDueDate({
    required String cardId,
    required DateTime dueDate,
    required String userUId,
  }) async {
    try {
      if (CardStatusValues.isDueDateInPast(dueDate)) {
        throw Exception(CardStatusValues.dueDateInPastMessage);
      }

      final response = await dio.put(
        '${ApiEndpoints.card}/$cardId/duedate',
        data: {'dueDate': dueDate.toIso8601String(), 'userUId': userUId},
      );
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
        return data
            .map((json) => CommentModel.fromJson(json).toEntity())
            .toList();
      }
      throw Exception('Lỗi khi lấy bình luận');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CommentEntity> addComment({
    required String cardId,
    required String content,
    required String userUId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.comments,
        data: {'cardUId': cardId, 'content': content, 'userUId': userUId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommentModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi thêm bình luận');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CommentEntity> updateComment({
    required String commentId,
    required String content,
    required String userUId,
  }) async {
    try {
      final response = await dio.put(
        '${ApiEndpoints.comments}/$commentId',
        data: {'content': content, 'userUId': userUId},
      );
      if (response.statusCode == 200) {
        return CommentModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lá»—i khi cáº­p nháº­t bÃ¬nh luáº­n');
    } catch (e) {
      throw Exception('Lá»—i káº¿t ná»‘i server: $e');
    }
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String userUId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.comments}/$commentId?userUId=$userUId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lá»—i khi xÃ³a bÃ¬nh luáº­n');
      }
    } catch (e) {
      throw Exception('Lá»—i káº¿t ná»‘i server: $e');
    }
  }

  @override
  Future<FileUrlEntity> uploadCommentAttachment({
    required String commentId,
    required String filePath,
    required String userUId,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await dio.post(
        '${ApiEndpoints.comments}/$commentId/attachments?userUId=$userUId',
        data: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FileUrlModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lá»—i khi táº£i lÃªn táº­p tin bÃ¬nh luáº­n');
    } catch (e) {
      throw Exception('Lá»—i káº¿t ná»‘i server: $e');
    }
  }

  @override
  Future<void> deleteCommentAttachment({
    required String commentId,
    required String fileId,
    required String userUId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.comments}/$commentId/attachments/$fileId?userUId=$userUId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lá»—i khi xÃ³a táº­p tin bÃ¬nh luáº­n');
      }
    } catch (e) {
      throw Exception('Lá»—i káº¿t ná»‘i server: $e');
    }
  }

  @override
  Future<List<CardMemberEntity>> getCardMembers({
    required String cardId,
  }) async {
    try {
      final response = await dio.get('${ApiEndpoints.cardMember}/$cardId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          return CardMemberEntity(
            id: json['id'] ?? json['cardMemberUId'] ?? '',
            userUId: json['userUId'] ?? '',
            userName: json['userName'] ?? json['fullName'] ?? 'Unknown',
            email: json['email'] ?? '',
            avatarUrl: json['avatarUrl'],
            role: json['role'] ?? 'Observer',
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
        return data
            .map((json) => TodoItemModel.fromJson(json).toEntity())
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi kết nối server khi lấy danh sách việc: $e');
    }
  }

  @override
  Future<List<FileUrlEntity>> getAttachments({required String cardId}) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.card}/$cardId/attachments',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => FileUrlModel.fromJson(json).toEntity())
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FileUrlEntity> uploadAttachment({
    required String cardId,
    required String filePath,
    required String userUId,
    String? description,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        if (description != null && description.isNotEmpty)
          "description": description,
      });

      final response = await dio.post(
        '${ApiEndpoints.card}/$cardId/attachments?userUId=$userUId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FileUrlModel.fromJson(response.data).toEntity();
      }
      if (response.statusCode == 409) {
        throw Exception('DUPLICATE');
      }
      throw Exception('Lỗi khi tải lên tập tin đính kèm');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) throw Exception('DUPLICATE');
      throw Exception('Lỗi kết nối server: $e');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<String> uploadCardCover({
    required String cardId,
    required String filePath,
    required String userUId,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.post(
        '${ApiEndpoints.card}/$cardId/upload-background?userUId=$userUId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] ?? '';
      }
      throw Exception('Lỗi khi tải lên ảnh bìa');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> deleteAttachment({
    required String cardId,
    required String fileId,
    required String userUId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.card}/$cardId/attachments/$fileId?userUId=$userUId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lỗi khi xóa tệp đính kèm');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> updateAttachmentDescription({
    required String cardId,
    required String fileId,
    required String userUId,
    String? description,
  }) async {
    try {
      final queryParam =
          'userUId=$userUId${description != null ? '&description=${Uri.encodeQueryComponent(description)}' : ''}';
      final response = await dio.put(
        '${ApiEndpoints.card}/$cardId/attachments/$fileId/description?$queryParam',
      );
      if (response.statusCode != 200) {
        throw Exception('Lỗi khi cập nhật mô tả tệp đính kèm');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<CardLabelEntity> addCardLabel({
    required String cardId,
    required String title,
    required String colorCode,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.card}/$cardId/labels',
        data: {'title': title, 'colorCode': colorCode},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CardLabelModel.fromJson(response.data).toEntity();
      }
      throw Exception('Lỗi khi thêm nhãn');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> deleteCardLabel({
    required String cardId,
    required String labelId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.card}/$cardId/labels/$labelId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Lỗi khi xóa nhãn');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<List<CardMemberEntity>> getBoardMembers({
    required String boardId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.boardMember}/$boardId/members',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          return CardMemberEntity(
            id: json['id'] ?? json['userUId'] ?? '',
            userUId: json['userUId'] ?? '',
            userName: json['userName'] ?? json['fullName'] ?? 'Unknown',
            email: json['email'] ?? '',
            avatarUrl: json['avatarUrl'],
            role: json['role'] ?? 'Viewer',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách thành viên bảng: $e');
    }
  }

  @override
  Future<void> addCardMember({
    required String cardId,
    required String userUId,
    required String requesterUId,
    required String boardId,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.cardMember}/add',
        queryParameters: {
          'userUId': userUId,
          'requesterUId': requesterUId,
          'boardUId': boardId,
          'cardUId': cardId,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Lỗi khi thêm thành viên vào thẻ');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> removeCardMember({
    required String cardId,
    required String userUId,
    required String requesterUId,
    required String boardId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.cardMember}/remove',
        queryParameters: {
          'userUId': userUId,
          'requesterUId': requesterUId,
          'boardUId': boardId,
          'cardUId': cardId,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Lỗi khi xóa thành viên khỏi thẻ');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> updateCardMemberRole({
    required String cardId,
    required String userUId,
    required String role,
    required String requesterUId,
    required String boardId,
  }) async {
    try {
      final response = await dio.put(
        '${ApiEndpoints.cardMember}/$cardId/update-role',
        queryParameters: {
          'userUId': userUId,
          'newRole': role,
          'requesterUId': requesterUId,
          'boardUId': boardId,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Lỗi khi cập nhật vai trò thành viên thẻ');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> archiveCard({
    required String cardId,
    required String userUId,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiEndpoints.card}/$cardId/archive?userUId=$userUId',
      );
      if (response.statusCode != 200) throw Exception('Lỗi khi lưu trữ thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> unarchiveCard({
    required String cardId,
    required String userUId,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiEndpoints.card}/$cardId/unarchive?userUId=$userUId',
      );
      if (response.statusCode != 200) throw Exception('Lỗi khi khôi phục thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  @override
  Future<void> joinCard({
    required String cardId,
    required String userUId,
    required String boardId,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.card}/$cardId/join?userUId=$userUId&boardId=$boardId',
      );
      if (response.statusCode != 200) throw Exception('Lỗi khi tham gia thẻ');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }
}
