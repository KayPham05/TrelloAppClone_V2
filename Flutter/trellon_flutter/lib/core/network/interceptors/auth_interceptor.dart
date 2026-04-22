import 'dart:async';

import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final CookieJar cookieJar;

  // === Token Refresh Queuing Mechanism ===
  // Ngăn chặn nhiều request gọi refresh-token cùng lúc
  bool _isRefreshing = false;
  final List<Completer<String?>> _pendingRequests = [];

  AuthInterceptor({required this.dio, required this.cookieJar});

  // --- 1. Đính kèm access_token vào mọi request ---
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final secureStorage = const FlutterSecureStorage();
    final String? token = await secureStorage.read(key: 'access_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  // --- 2. Bắt lỗi 401, tự động refresh token rồi retry ---
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Chỉ xử lý 401 và không phải chính request refresh-token
    if (err.response?.statusCode == 401 &&
        !(err.requestOptions.path.contains(ApiEndpoints.refreshToken))) {
      
      // Nếu đang có request refresh đang chạy, đưa request này vào hàng chờ
      if (_isRefreshing) {
        final completer = Completer<String?>();
        _pendingRequests.add(completer);

        final newToken = await completer.future;
        if (newToken != null) {
          return handler.resolve(await _retryRequest(err.requestOptions, newToken));
        } else {
          return handler.next(err); // Refresh thất bại, trả lỗi
        }
      }

      _isRefreshing = true;

      try {
        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          // Lưu access token mới
          final secureStorage = const FlutterSecureStorage();
          await secureStorage.write(key: 'access_token', value: newAccessToken);

          // Thông báo thành công cho tất cả request đang chờ
          for (final c in _pendingRequests) {
            c.complete(newAccessToken);
          }
          _pendingRequests.clear();

          // Retry request gốc với token mới
          return handler.resolve(await _retryRequest(err.requestOptions, newAccessToken));
        } else {
          // Refresh thất bại → xóa hết data và buộc về login
          await _clearSessionAndLogout();
          for (final c in _pendingRequests) {
            c.complete(null);
          }
          _pendingRequests.clear();
          return handler.next(err);
        }
      } catch (e) {
        await _clearSessionAndLogout();
        for (final c in _pendingRequests) {
          c.complete(null);
        }
        _pendingRequests.clear();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  // --- Helper: Gọi API refresh-token ---
  Future<String?> _refreshToken() async {
    try {
      final secureStorage = const FlutterSecureStorage();
      final String? oldRefreshToken = await secureStorage.read(key: 'refresh_token');

      // Cookie refreshToken sẽ được tự động gửi qua CookieManager
      // Nhưng ta vẫn gửi kèm trong body để dự phòng nếu Cookie Manager không đẩy lên
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': oldRefreshToken},
        options: Options(
          // Bỏ qua interceptor này cho request refresh để tránh vòng lặp vô hạn
          extra: {'skipAuthInterceptor': true},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['accessToken'] as String?;
      }
    } on DioException {
      return null;
    }
    return null;
  }

  // --- Helper: Retry lại request với token mới ---
  Future<Response<dynamic>> _retryRequest(
      RequestOptions options, String newToken) async {
    options.headers['Authorization'] = 'Bearer $newToken';
    return dio.fetch(options);
  }

  // --- Helper: Xóa session cục bộ khi refresh thất bại ---
  Future<void> _clearSessionAndLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.setBool('isLogged', false);

    final secureStorage = const FlutterSecureStorage();
    await secureStorage.deleteAll();

    // Xóa hết cookie (refreshToken)
    await cookieJar.deleteAll();
    // Điều hướng sẽ được xử lý ở UI layer thông qua NavigatorService hoặc StreamController
    // TODO: Emit logout event nếu cần điều hướng toàn cục từ đây
  }
}