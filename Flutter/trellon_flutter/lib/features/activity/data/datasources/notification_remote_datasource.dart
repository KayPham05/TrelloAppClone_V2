import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({required int page, required int pageSize});
  Future<bool> markAsRead({required String notiId});
  Future<int> markAllAsRead();
  Future<bool> deleteNotification({required String notiId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications({required int page, required int pageSize}) async {
    try {
      final response = await dio.get('${ApiEndpoints.notifications}?page=$page&pageSize=$pageSize');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load notifications");
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? "Lỗi kết nối";
      throw Exception(message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  @override
  Future<bool> markAsRead({required String notiId}) async {
    try {
      final response = await dio.patch('${ApiEndpoints.notifications}/$notiId/read');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Không thể đánh dấu đã đọc");
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final response = await dio.patch('${ApiEndpoints.notifications}/read-all');
      if (response.statusCode == 200) {
        return 1;
      }
      return 0;
    } catch (e) {
      throw Exception("Không thể đánh dấu tất cả đã đọc");
    }
  }

  @override
  Future<bool> deleteNotification({required String notiId}) async {
    try {
      final response = await dio.delete('${ApiEndpoints.notifications}/$notiId');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Không thể xóa thông báo");
    }
  }
}
