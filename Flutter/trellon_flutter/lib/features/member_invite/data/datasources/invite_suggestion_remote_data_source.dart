import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/invite_suggestion_model.dart';

class InviteSuggestionRemoteDataSource {
  final Dio client;

  InviteSuggestionRemoteDataSource({required this.client});

  Future<List<InviteSuggestionModel>> search({
    required String query,
    required String scope,
    required String requesterUId,
    String? workspaceId,
    String? boardId,
    int limit = 10,
  }) async {
    try {
      final response = await client.get(
        ApiEndpoints.inviteSuggestions,
        queryParameters: {
          'query': query,
          'scope': scope,
          'requesterUId': requesterUId,
          'workspaceId': ?workspaceId,
          'boardId': ?boardId,
          'limit': limit,
        },
      );

      final data = response.data as List;
      return data
          .map(
            (item) =>
                InviteSuggestionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw Exception('Bạn không có quyền tìm kiếm thành viên để mời.');
      }
      throw Exception('Không thể tải gợi ý thành viên.');
    } catch (_) {
      throw Exception('Không thể tải gợi ý thành viên.');
    }
  }
}
