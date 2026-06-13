import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/workspace_entity.dart';
import '../models/workspace_model.dart';
import '../../../board/data/models/board_model.dart';

class WorkspaceRemoteDataSource {
  final Dio client;

  WorkspaceRemoteDataSource({required this.client});

  Future<List<WorkspaceModel>> getWorkspaces(String userUid) async {
    try {
      final response = await client.get(
        ApiEndpoints.workspace,
        queryParameters: {'userUid': userUid},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => WorkspaceModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to load workspaces: $e');
    }
  }

  Future<List<BoardModel>> getWorkspaceBoards(
    String workspaceId,
    String userUid,
  ) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.workspace}/$workspaceId/boards',
        queryParameters: {'userUId': userUid},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => BoardModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to load workspace boards: $e');
    }
  }

  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String? description,
    required String type,
    required String userUId,
  }) async {
    final response = await client.post(
      '${ApiEndpoints.workspace}/create',
      queryParameters: {
        'creatorUserId': userUId,
        'name': name,
        'description': description,
        'type': type,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map && response.data['message'] != null) {
        return WorkspaceModel(
          id: '',
          name: name,
          description: description ?? '',
          type: WorkspaceTypeExtension.fromString(type),
          ownerUId: userUId,
          boards: const [],
        );
      }
      return WorkspaceModel.fromJson(response.data);
    }
    throw Exception('Failed to create workspace');
  }

  Future<void> updateWorkspace({
    required String workspaceId,
    required String name,
    required String? description,
    required String type,
    required String userUId,
  }) async {
    final response = await client.put(
      '${ApiEndpoints.workspace}/update',
      data: {
        'workspaceId': workspaceId,
        'name': name,
        'description': description,
        'requesterUId': userUId,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update workspace');
    }
  }

  Future<void> deleteWorkspace({
    required String workspaceId,
    required String userUId,
  }) async {
    final response = await client.delete(
      '${ApiEndpoints.workspace}/delete',
      queryParameters: {'workspaceId': workspaceId, 'requestUserId': userUId},
    );
    if (response.statusCode == 200) {
      if (response.data is Map &&
          response.data['message'] == 'Không có quyền') {
        throw Exception('Bạn không có quyền xóa không gian này');
      }
    }
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete workspace');
    }
  }

  Future<void> addWorkspaceMember({
    required String workspaceId,
    required String userId,
    required String role,
    required String requesterUId,
  }) async {
    final response = await client.post(
      '${ApiEndpoints.workspaceMember}/$workspaceId/invite',
      data: {'userId': userId, 'role': role, 'requesterUId': requesterUId},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add workspace member');
    }
  }

  Future<void> updateBoardVisibility({
    required String boardId,
    required String boardName,
    required String workspaceId,
    required String visibility,
    required String userUId,
  }) async {
    final response = await client.put(
      '${ApiEndpoints.boards}/$boardId',
      data: {
        'boardUId': boardId,
        'boardName': boardName,
        'workspaceUId': workspaceId,
        'visibility': visibility,
      },
      queryParameters: {'userUId': userUId},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update board visibility');
    }
  }
}
