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
      final response = await client.get(ApiEndpoints.workspace, queryParameters: {'userUid': userUid});
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

  Future<List<BoardModel>> getWorkspaceBoards(String workspaceId, String userUid) async {
    try {
      final response = await client.get('${ApiEndpoints.workspace}/$workspaceId/boards', queryParameters: {'userUId': userUid});
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
      '${ApiEndpoints.workspace}/$workspaceId',
      data: {
        'workspaceUId': workspaceId,
        'name': name,
        'description': description,
        'type': type,
        'userUId': userUId,
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
    final response = await client.put(
      '${ApiEndpoints.workspace}/$workspaceId',
      queryParameters: {'newStatus': 'Deleted', 'userUId': userUId},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete workspace');
    }
  }

  Future<void> addWorkspaceMember({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    final response = await client.post(
      ApiEndpoints.workspaceMember,
      data: {
        'workspaceUId': workspaceId,
        'email': email,
        'role': role,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add workspace member');
    }
  }
}
