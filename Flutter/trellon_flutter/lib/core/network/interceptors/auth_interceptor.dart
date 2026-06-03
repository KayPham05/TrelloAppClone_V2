import 'dart:async';

import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../../init_dependencies.dart';
import '../../../features/activity/presentation/cubit/notification_cubit.dart';

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
    final isLocked = err.response?.statusCode == 403 &&
        err.response?.data != null &&
        err.response?.data is Map &&
        err.response?.data['message'] == 'ACCOUNT_LOCKED';

    if (isLocked) {
      final email = err.response?.data['email'] ?? '';
      await _clearSessionAndLogout(isLocked: true, email: email);
      return handler.next(err);
    }

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
      } catch (e) {
        bool isLocked = false;
        String lockedEmail = '';
        if (e.toString().contains('ACCOUNT_LOCKED|')) {
          isLocked = true;
          lockedEmail = e.toString().split('|').last;
        }

        await _clearSessionAndLogout(isLocked: isLocked, email: lockedEmail);

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 && e.response?.data != null) {
        if (e.response?.data['message'] == 'ACCOUNT_LOCKED') {
          throw Exception('ACCOUNT_LOCKED|${e.response?.data['email']}');
        }
      }
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

  Future<void> _clearSessionAndLogout({bool isLocked = false, String email = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.setBool('isLogged', false);

    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();

    await cookieJar.deleteAll();

    serviceLocator<NotificationCubit>().reset();

    if (isLocked) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/locked-account',
        (route) => false,
        arguments: email,
      );
    } else {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
