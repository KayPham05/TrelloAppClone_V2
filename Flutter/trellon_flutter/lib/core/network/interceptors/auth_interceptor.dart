import 'dart:async';

import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final CookieJar cookieJar;

  bool _isRefreshing = false;
  final List<Completer<String?>> _pendingRequests = [];

  AuthInterceptor({
    required this.dio,
    required this.cookieJar,
  });

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (options.extra['skipAuthInterceptor'] == true) {
      return handler.next(options);
    }

    final secureStorage = const FlutterSecureStorage();
    final token = await secureStorage.read(key: 'access_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshRequest =
    err.requestOptions.path.contains(ApiEndpoints.refreshToken);
    final shouldSkip = err.requestOptions.extra['skipAuthInterceptor'] == true;

    if (isUnauthorized && !isRefreshRequest && !shouldSkip) {
      if (_isRefreshing) {
        final completer = Completer<String?>();
        _pendingRequests.add(completer);

        final newToken = await completer.future;

        if (newToken != null) {
          return handler.resolve(
            await _retryRequest(err.requestOptions, newToken),
          );
        }

        return handler.next(err);
      }

      _isRefreshing = true;

      try {
        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          final secureStorage = const FlutterSecureStorage();
          await secureStorage.write(
            key: 'access_token',
            value: newAccessToken,
          );

          for (final request in _pendingRequests) {
            request.complete(newAccessToken);
          }
          _pendingRequests.clear();

          return handler.resolve(
            await _retryRequest(err.requestOptions, newAccessToken),
          );
        }

        await _clearSessionAndLogout();

        for (final request in _pendingRequests) {
          request.complete(null);
        }
        _pendingRequests.clear();

        return handler.next(err);
      } catch (_) {
        await _clearSessionAndLogout();

        for (final request in _pendingRequests) {
          request.complete(null);
        }
        _pendingRequests.clear();

        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final secureStorage = const FlutterSecureStorage();
      final oldRefreshToken = await secureStorage.read(key: 'refresh_token');

      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': oldRefreshToken},
        options: Options(
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

  Future<Response<dynamic>> _retryRequest(
      RequestOptions options,
      String newToken,
      ) async {
    options.headers['Authorization'] = 'Bearer $newToken';
    return dio.fetch(options);
  }

  Future<void> _clearSessionAndLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.setBool('isLogged', false);

    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();

    await cookieJar.deleteAll();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }
}