import 'package:dio/dio.dart';

class AppExceptionMapper {
  static String map(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Kết nối quá lâu. Vui lòng kiểm tra mạng và thử lại.';

        case DioExceptionType.connectionError:
          return 'Không thể kết nối máy chủ. Vui lòng kiểm tra Internet hoặc API URL.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (statusCode == 401) {
            return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
          }

          if (statusCode == 403) {
            return 'Bạn không có quyền thực hiện thao tác này.';
          }

          if (statusCode == 404) {
            return 'Không tìm thấy dữ liệu yêu cầu.';
          }

          if (data is Map && data['message'] != null) {
            return data['message'].toString();
          }

          if (data is String && data.trim().isNotEmpty) {
            return data.trim();
          }

          return 'Máy chủ trả về lỗi ${statusCode ?? ''}.';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy.';

        default:
          return 'Không thể xử lý yêu cầu. Vui lòng thử lại.';
      }
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? 'Đã xảy ra lỗi không xác định.' : message;
  }
}