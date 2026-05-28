import 'package:dio/dio.dart';

class AppExceptionMapper {
  static String map(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }

    return _mapTextError(error.toString());
  }

  static String _mapDioException(DioException error) {
    final directMessage = _messageByDioType(error.type);

    if (directMessage != null) {
      return directMessage;
    }

    if (error.type == DioExceptionType.badResponse) {
      return _mapBadResponse(error.response);
    }

    return 'Không thể xử lý yêu cầu. Vui lòng thử lại.';
  }

  static String? _messageByDioType(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá lâu. Vui lòng kiểm tra mạng và thử lại.';

      case DioExceptionType.connectionError:
        return 'Không thể kết nối máy chủ. Vui lòng kiểm tra Internet hoặc API URL.';

      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';

      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return null;
    }
  }

  static String _mapBadResponse(Response<dynamic>? response) {
    final statusMessage = _messageByStatusCode(response?.statusCode);

    if (statusMessage != null) {
      return statusMessage;
    }

    final serverMessage = _messageFromResponseData(response?.data);

    if (serverMessage != null) {
      return serverMessage;
    }

    final statusCode = response?.statusCode;

    return statusCode == null
        ? 'Máy chủ trả về lỗi.'
        : 'Máy chủ trả về lỗi $statusCode.';
  }

  static String? _messageByStatusCode(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy dữ liệu yêu cầu.';
      default:
        return null;
    }
  }

  static String? _messageFromResponseData(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return null;
  }

  static String _mapTextError(String rawMessage) {
    final message = rawMessage.replaceFirst('Exception: ', '').trim();

    if (message.isEmpty) {
      return 'Đã xảy ra lỗi không xác định.';
    }

    final mappedMessage = _messageByText(message.toLowerCase());

    return mappedMessage ?? message;
  }

  static String? _messageByText(String message) {
    if (_containsAny(message, ['timeout', 'connectiontimeout', 'receivetimeout'])) {
      return 'Kết nối quá lâu. Vui lòng kiểm tra mạng và thử lại.';
    }

    if (_containsAny(message, ['connection error', 'socketexception', 'failed host lookup'])) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra Internet hoặc API URL.';
    }

    if (_containsAny(message, ['401', 'unauthorized'])) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

    return null;
  }

  static bool _containsAny(String source, List<String> keywords) {
    return keywords.any(source.contains);
  }
}