import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/project_analysis_model.dart';

abstract class AiAnalysisRemoteDataSource {
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    required String userUId,
  });

  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    required String userUId,
  });

  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    required String userUId,
  });
}

class AiAnalysisRemoteDataSourceImpl implements AiAnalysisRemoteDataSource {
  final Dio client;

  AiAnalysisRemoteDataSourceImpl({required this.client});

  @override
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    required String userUId,
  }) {
    return _get('${ApiEndpoints.analysis}/workspace/$workspaceUId', userUId);
  }

  @override
  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    required String userUId,
  }) {
    return _get('${ApiEndpoints.analysis}/board/$boardUId', userUId);
  }

  @override
  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    required String userUId,
  }) {
    return _get('${ApiEndpoints.analysis}/card/$cardUId', userUId);
  }

  Future<ProjectAnalysisModel> _get(String path, String userUId) async {
    try {
      final response = await client.get(
        path,
        queryParameters: {'userUId': userUId},
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
