import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'interceptors/auth_interceptor.dart';

class DioClient {
  late Dio _dio;
  late CookieJar cookieJar;

  /// [persistentCookieJar] — nếu truyền vào thì dùng PersistCookieJar
  /// (lưu cookie xuống disk), ngược lại fallback về in-memory CookieJar.
  DioClient({CookieJar? persistentCookieJar}) {
    cookieJar = persistentCookieJar ?? CookieJar();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ),
    );

    // Thêm các Interceptors theo thứ tự
    _dio.interceptors.addAll([
      CookieManager(cookieJar), // Tự động lưu & gửi cookie (refreshToken)
      AuthInterceptor(dio: _dio, cookieJar: cookieJar), // Xử lý Token & Auto-Refresh
      LogInterceptor(responseBody: true),
    ]);
  }

  Dio get instance => _dio;
}
