import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/project_analysis_model.dart';
import '../models/report_history_item_model.dart';

abstract class AiAnalysisRemoteDataSource {
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    bool forceRefresh = false,
  });

  Future<ReportHistoryPageModel> getReportHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  });

  Future<ReportHistoryItemModel> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  });

  Future<ProjectAnalysisModel> getReportById({required String reportUId});
}

class AiAnalysisRemoteDataSourceImpl implements AiAnalysisRemoteDataSource {
  final Dio client;

  AiAnalysisRemoteDataSourceImpl({required this.client});

  @override
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    bool forceRefresh = false,
  }) {
    return _get(
      '${ApiEndpoints.analysis}/workspace/$workspaceUId',
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    bool forceRefresh = false,
  }) {
    return _get(
      '${ApiEndpoints.analysis}/board/$boardUId',
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    bool forceRefresh = false,
  }) {
    return _get(
      '${ApiEndpoints.analysis}/card/$cardUId',
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<ReportHistoryPageModel> getReportHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.analysis}/history/$scopeType/$scopeUId',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final data = response.data;
      if (data is Map) {
        return ReportHistoryPageModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Phản hồi lịch sử báo cáo không hợp lệ.');
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<ReportHistoryItemModel> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  }) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.analysis}/report/save/$scopeType/$scopeUId',
      );
      final data = response.data;
      if (data is Map) {
        return ReportHistoryItemModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Phản hồi lưu báo cáo không hợp lệ.');
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<ProjectAnalysisModel> getReportById({required String reportUId}) {
    return _get('${ApiEndpoints.analysis}/report/$reportUId');
  }

  Future<ProjectAnalysisModel> _get(
    String path, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await client.get(
        path,
        queryParameters: {if (forceRefresh) 'forceRefresh': true},
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
