import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/list_model.dart';
import '../../../card/data/models/card_model.dart';

/// Remote data source for board detail operations
class BoardDetailRemoteDataSource {
  final Dio dio;

  BoardDetailRemoteDataSource({required this.dio});

  Future<List<ListModel>> getLists(String boardId) async {
    final response = await dio.get(
      ApiEndpoints.lists,
      queryParameters: {'boardUId': boardId},
    );
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => ListModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load lists');
  }

  Future<List<CardModel>> getCardsByBoard(String boardId) async {
    final response = await dio.get('${ApiEndpoints.card}/by-board/$boardId');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => CardModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load cards');
  }

  Future<ListModel> createList({
    required String boardId,
    required String name,
    required String userUId,
    required int position,
  }) async {
    final response = await dio.post(
      ApiEndpoints.lists,
      data: {
        'listName': name,
        'boardUId': boardId,
        'position': position,
        'status': 'Active',
      },
      queryParameters: {'userUId': userUId},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ListModel.fromJson(response.data);
    }
    throw Exception('Failed to create list');
  }

  Future<void> moveCard({
    required String cardId,
    required String newListId,
    required String userUId,
  }) async {
    final response = await dio.put(
      '${ApiEndpoints.card}/$cardId/update-list',
      data: {
        'listUId': newListId,
        'userUId': userUId,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to move card');
    }
  }

  Future<void> reorderLists({
    required String boardId,
    required List<ListModel> lists,
  }) async {
    final order = lists.map((l) => {
      'listUId': l.id,
      'position': l.position,
    }).toList();

    final response = await dio.put(
      '${ApiEndpoints.lists}/reorder',
      data: {
        'boardUId': boardId,
        'order': order,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reorder lists');
    }
  }

  Future<CardModel> createCard({
    required String listId,
    required String title,
    required int position,
  }) async {
    final response = await dio.post(
      ApiEndpoints.card,
      data: {
        'listUId': listId,
        'title': title,
        'position': position,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // API returns a simple ok string, try to parse; fall back to a minimal card
      if (response.data is Map) {
        return CardModel.fromJson(response.data);
      }
      // The C# POST /cards API returns a string success, not a card object. 
      // Return minimal model so UI can refetch
      return CardModel(
        id: '',
        title: title,
        position: position,
        listId: listId,
      );
    }
    throw Exception('Failed to create card');
  }

  Future<void> deleteList({required String listId, required String userUId}) async {
    await dio.put(
      '${ApiEndpoints.lists}/$listId',
      queryParameters: {'newStatus': 'Deleted', 'userUId': userUId},
    );
  }

  Future<void> updateBoardBackground({
    required String boardId,
    required String boardName,
    required String backgroundUrl,
  }) async {
    await dio.put(
      '${ApiEndpoints.boards}/$boardId',
      data: {
        'boardUId': boardId,
        'boardName': boardName,
        'backgroundUrl': backgroundUrl,
      },
    );
  }

  Future<String> uploadBoardBackground({
    required String boardId,
    required String filePath,
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      '${ApiEndpoints.boards}/$boardId/upload-background',
      data: formData,
    );
    if (response.statusCode == 200) {
      return response.data['url'] ?? '';
    }
    throw Exception('Failed to upload background');
  }
}
