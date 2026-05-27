import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationPageModel> getNotifications({
    required int page,
    required int pageSize,
    required String tab,
  });
  Future<bool> markAsRead({required String notiId});
  Future<int> markAllAsRead();
  Future<bool> deleteNotification({required String notiId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<NotificationPageModel> getNotifications({
    required int page,
    required int pageSize,
    required String tab,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'tab': tab,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return NotificationPageModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw Exception('Failed to load notifications');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Connection error';
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<bool> markAsRead({required String notiId}) async {
    try {
      final response = await dio.patch('${ApiEndpoints.notifications}/$notiId/read');
      return response.statusCode == 200;
    } catch (_) {
      throw Exception('Could not mark notification as read');
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final response = await dio.patch('${ApiEndpoints.notifications}/read-all');
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['updatedCount'] ?? 0;
      }
      return 0;
    } catch (_) {
      throw Exception('Could not mark all notifications as read');
    }
  }

  @override
  Future<bool> deleteNotification({required String notiId}) async {
    try {
      final response = await dio.delete('${ApiEndpoints.notifications}/$notiId');
      return response.statusCode == 200;
    } catch (_) {
      throw Exception('Could not delete notification');
    }
  }
}
