import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/board_model.dart';
import '../models/list_model.dart';
import '../../../card/data/models/card_model.dart';

abstract class BoardRemoteDataSource {
  // Board CRUD
  Future<List<BoardModel>> getRecentBoards(String userUid);
  Future<List<BoardModel>> getAllBoards(String userUid);
  Future<BoardModel?> getBoardById(String boardId);
  Future<void> createBoard({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  });
  Future<void> updateBoard({
    required String boardId,
    required String boardName,
    required String userUId,
    String? backgroundUrl,
    String? visibility,
    String? workspaceUId,
  });
  Future<void> updateBoardBackground({
    required String boardId,
    required String boardName,
    required String backgroundUrl,
    required String userUId,
  });
  Future<String> uploadBoardBackground({
    required String boardId,
    required String filePath,
    required String userUId,
  });
  Future<bool> transferBoardWorkspace({
    required String boardId,
    required String newWorkspaceUId,
    required String requesterUId,
  });

  // Board Detail (Lists & Cards)
  Future<List<ListModel>> getLists(String boardId);
  Future<List<CardModel>> getCardsByBoard(String boardId);
  Future<List<CardModel>> getArchivedCards(String boardId);
  Future<void> restoreCard({required String cardId, required String userUId});
  Future<ListModel> createList({
    required String boardId,
    required String name,
    required String userUId,
    required int position,
  });
  Future<void> deleteList({required String listId, required String userUId});
  Future<void> reorderLists({
    required String boardId,
    required List<ListModel> lists,
    required String userUId,
  });
  Future<CardModel> createCard({
    required String listId,
    required String title,
    required int position,
    required String userUId,
  });
  Future<void> moveCard({
    required String cardId,
    required String newListId,
    required String userUId,
  });

  // Board Members
  Future<List<dynamic>> getBoardMembers(String boardId);
  Future<String?> getUserRoleInBoard({required String boardId, required String userUId});
  Future<bool> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required String requesterUId,
  });
  Future<bool> updateBoardMemberRole({
    required String boardId,
    required String userId,
    required String newRole,
    required String requesterUId,
  });
  Future<bool> removeBoardMember({
    required String boardId,
    required String userId,
    required String requesterUId,
  });

  // Workspaces
  Future<List<dynamic>> getWorkspaces(String userUid);

  // Helper for member management
  Future<Map<String, dynamic>?> findUserByEmail(String email);
  Future<List<dynamic>> getWorkspaceMembers(String workspaceId);
}

class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final Dio client;

  BoardRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BoardModel>> getRecentBoards(String userUid) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.boards}/${ApiEndpoints.recentBoards}',
        queryParameters: {'userUId': userUid},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) {
          final boardMap = json['board'] ?? json;
          return BoardModel.fromJson(boardMap);
        }).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      throw Exception('Failed to load recent boards: $e');
    }
  }

  @override
  Future<List<BoardModel>> getAllBoards(String userUid) async {
    try {
      final response = await client.get(
        ApiEndpoints.boards,
        queryParameters: {'userUId': userUid},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => BoardModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      throw Exception('Failed to load all boards: $e');
    }
  }

  @override
  Future<BoardModel?> getBoardById(String boardId) async {
    try {
      final response = await client.get('${ApiEndpoints.boards}/$boardId');
      if (response.statusCode == 200) {
        return BoardModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load board: $e');
    }
  }

  @override
  Future<void> createBoard({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  }) async {
    try {
      await client.post(
        ApiEndpoints.boards,
        data: {
          'boardName': name,
          'userUId': userUid,
          'workspaceUId': workspaceId,
          'backgroundUrl': backgroundUrl,
          'visibility': visibility ?? 'Private',
          'isPersonal': isPersonal,
          'status': 'Active',
        },
      );
    } catch (e) {
      throw Exception('Failed to create board: $e');
    }
  }

  @override
  Future<void> updateBoard({
    required String boardId,
    required String boardName,
    required String userUId,
    String? backgroundUrl,
    String? visibility,
    String? workspaceUId,
  }) async {
    final body = <String, dynamic>{
      'boardUId': boardId,
      'boardName': boardName,
    };
    if (backgroundUrl != null) body['backgroundUrl'] = backgroundUrl;
    if (visibility != null) body['visibility'] = visibility;
    if (workspaceUId != null) body['workspaceUId'] = workspaceUId;
    await client.put(
      '${ApiEndpoints.boards}/$boardId',
      data: body,
      queryParameters: {'userUId': userUId},
    );
  }

  @override
  Future<void> updateBoardBackground({
    required String boardId,
    required String boardName,
    required String backgroundUrl,
    required String userUId,
  }) async {
    await client.put(
      '${ApiEndpoints.boards}/$boardId',
      data: {
        'boardUId': boardId,
        'boardName': boardName,
        'backgroundUrl': backgroundUrl,
      },
      queryParameters: {'userUId': userUId},
    );
  }

  @override
  Future<bool> transferBoardWorkspace({
    required String boardId,
    required String newWorkspaceUId,
    required String requesterUId,
  }) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.boardMember}/$boardId/transfer-workspace',
        queryParameters: {
          'newWorkspaceUId': newWorkspaceUId,
          'requesterUId': requesterUId,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> uploadBoardBackground({
    required String boardId,
    required String filePath,
    required String userUId,
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await client.post(
      '${ApiEndpoints.boards}/$boardId/upload-background',
      data: formData,
      queryParameters: {'userUId': userUId},
    );
    if (response.statusCode == 200) {
      return response.data['url'] ?? '';
    }
    throw Exception('Failed to upload background');
  }

  @override
  Future<List<ListModel>> getLists(String boardId) async {
    final response = await client.get(
      ApiEndpoints.lists,
      queryParameters: {'boardUId': boardId},
    );
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => ListModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load lists');
  }

  @override
  Future<List<CardModel>> getCardsByBoard(String boardId) async {
    final response = await client.get('${ApiEndpoints.card}/by-board/$boardId');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => CardModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load cards');
  }

  @override
  Future<List<CardModel>> getArchivedCards(String boardId) async {
    try {
      final response = await client.get('${ApiEndpoints.card}/by-board/$boardId');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data
            .map((json) => CardModel.fromJson(json))
            .where((c) => c.status == 'Archived' || c.status == 'Closed')
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> restoreCard({required String cardId, required String userUId}) async {
    await client.put(
      '${ApiEndpoints.card}/$cardId',
      data: {'status': 'Active', 'userUId': userUId},
    );
  }

  @override
  Future<ListModel> createList({
    required String boardId,
    required String name,
    required String userUId,
    required int position,
  }) async {
    final response = await client.post(
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

  @override
  Future<void> deleteList({required String listId, required String userUId}) async {
    await client.put(
      '${ApiEndpoints.lists}/$listId',
      queryParameters: {'newStatus': 'Deleted', 'userUId': userUId},
    );
  }

  @override
  Future<void> reorderLists({
    required String boardId,
    required List<ListModel> lists,
    required String userUId,
  }) async {
    final order = lists.map((l) => {
      'listUId': l.id,
      'position': l.position,
    }).toList();

    final response = await client.put(
      '${ApiEndpoints.lists}/reorder',
      data: {
        'boardUId': boardId,
        'order': order,
      },
      queryParameters: {'userUId': userUId},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reorder lists');
    }
  }

  @override
  Future<CardModel> createCard({
    required String listId,
    required String title,
    required int position,
    required String userUId,
  }) async {
    final response = await client.post(
      ApiEndpoints.card,
      data: {
        'listUId': listId,
        'title': title,
        'position': position,
        'userUId': userUId,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map) {
        return CardModel.fromJson(response.data);
      }
      return CardModel(
        id: '',
        title: title,
        position: position,
        listId: listId,
      );
    }
    throw Exception('Failed to create card');
  }

  @override
  Future<void> moveCard({
    required String cardId,
    required String newListId,
    required String userUId,
  }) async {
    final response = await client.put(
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

  @override
  Future<List<dynamic>> getBoardMembers(String boardId) async {
    final response = await client.get(
      '${ApiEndpoints.boardMember}/$boardId/members',
    );
    if (response.statusCode == 200) {
      return response.data as List;
    }
    throw Exception('Failed to load board members');
  }

  @override
  Future<String?> getUserRoleInBoard({required String boardId, required String userUId}) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.boardMember}/$boardId/role',
        queryParameters: {'userUId': userUId},
      );
      if (response.statusCode == 200) {
        return response.data['role'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required String requesterUId,
  }) async {
    final response = await client.post(
      '${ApiEndpoints.boardMember}/$boardId/add',
      queryParameters: {
        'userUId': userId,
        'requesterUId': requesterUId,
        'role': role,
      },
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> updateBoardMemberRole({
    required String boardId,
    required String userId,
    required String newRole,
    required String requesterUId,
  }) async {
    final response = await client.put(
      '${ApiEndpoints.boardMember}/$boardId/update-role',
      queryParameters: {
        'userUId': userId,
        'newRole': newRole,
        'requesterUId': requesterUId,
      },
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> removeBoardMember({
    required String boardId,
    required String userId,
    required String requesterUId,
  }) async {
    final response = await client.delete(
      '${ApiEndpoints.boardMember}/$boardId/remove/$userId',
      queryParameters: {'requesterUId': requesterUId},
    );
    return response.statusCode == 200;
  }

  @override
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final response = await client.get(
        'users/search',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<dynamic>> getWorkspaceMembers(String workspaceId) async {
    try {
      final response = await client.get('${ApiEndpoints.workspaceMember}/$workspaceId');
      if (response.statusCode == 200) {
        return response.data as List;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<dynamic>> getWorkspaces(String userUid) async {
    try {
      final response = await client.get(
        ApiEndpoints.workspace,
        queryParameters: {'userUid': userUid},
      );
      if (response.statusCode == 200) {
        return response.data as List;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
