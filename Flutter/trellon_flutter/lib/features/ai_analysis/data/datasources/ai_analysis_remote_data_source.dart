import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/project_analysis_model.dart';

abstract class AiAnalysisRemoteDataSource {
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    required String userUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    required String userUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    required String userUId,
    bool forceRefresh = false,
  });
}

class AiAnalysisRemoteDataSourceImpl implements AiAnalysisRemoteDataSource {
  final Dio client;

  AiAnalysisRemoteDataSourceImpl({required this.client});

  @override
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    required String userUId,
    bool forceRefresh = false,
  }) {
    return _get(
      '${ApiEndpoints.analysis}/workspace/$workspaceUId',
      userUId,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    required String userUId,
    bool forceRefresh = false,
  }) {
    return _get(
      '${ApiEndpoints.analysis}/board/$boardUId',
      userUId,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    required String userUId,
    bool forceRefresh = false,
  }) {
    return _get(
      '${ApiEndpoints.analysis}/card/$cardUId',
      userUId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ProjectAnalysisModel> _get(
    String path,
    String userUId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await client.get(
        path,
        queryParameters: {
          'userUId': userUId,
          if (forceRefresh) 'forceRefresh': true,
        },
      );
      final data = response.data;
      if (data is Map) {
        return ProjectAnalysisModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Phản hồi phân tích không hợp lệ.');
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return error.message ?? 'Không thể tải báo cáo phân tích.';
  }
}
