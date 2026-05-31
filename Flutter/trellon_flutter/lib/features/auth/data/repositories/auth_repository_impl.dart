import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../../../../core/constants/api_endpoints.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  AuthRepositoryImpl(this.dio);

  @override
  Future<UserEntity> register({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      final requestModel = RegisterRequestModel(
        userName: userName,
        email: email,
        password: password,
      );
      final response = await dio.post(
        ApiEndpoints.register,
        data: requestModel.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Sau register, BE trả email để navigate sang VerifyPage
        if (data['isMember'] == true) {
          throw Exception("Tài khoản này đã tồn tại trong hệ thống.");
        }
        return UserEntity(
          id: '',
          userName: data['userName'] ?? userName,
          email: data['email'] ?? email,
          requiresVerification: true,
        );
      }
      throw Exception("Đăng ký không thành công");
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = "Lỗi kết nối Server";
      if (data is Map) {
        errorMsg = data['message'] ?? errorMsg;
      } else if (data is String) {
        errorMsg = data.trim();
      }
      throw Exception(errorMsg);
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final requestModel = LoginRequesterModle(
        email: email,
        password: password,
      );
      final response = await dio.post(
        ApiEndpoints.login,
        data: requestModel.toJson(),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final requiresVerification =
            data['requiresVerification'] as bool? ?? false;
        final requires2FA = data['requires2FA'] as bool? ?? false;
        final msg = data['message'] as String? ?? '';

        if (requiresVerification && msg.contains('bị khóa')) {
          throw Exception('ACCOUNT_LOCKED|${data['email'] ?? email}');
        }

        // Email chưa verify hoặc Cần 2FA → trả entity với flag để cubit xử lý
        if (requiresVerification ||
            requires2FA ||
            (token == null || token.isEmpty)) {
          return UserEntity(
            id: data['userUId'] ?? '', // Cần userUId để verify 2FA
            userUId: data['userUId'] ?? '',
            userName: '',
            email: data['email'] ?? email,
            requiresVerification: requiresVerification,
            requires2FA: requires2FA,
          );
        }

        return UserEntity(
          id: data['userUId'] ?? '',
          userUId: data['userUId'] ?? '',
          userName: data['userName'] ?? '',
          email: data['email'] ?? '',
          token: token,
          refreshToken: refreshToken,
        );
      }
      throw Exception("Đăng nhập không thành công");
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = "Lỗi kết nối Server";
      if (data is Map) {
        errorMsg = data['message'] ?? errorMsg;
      } else if (data is String) {
        errorMsg = data.trim();
      }
      throw Exception(errorMsg);
    }
  }

  @override
  Future<UserEntity> googleLogin({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final payload = <String, dynamic>{
        'idToken': idToken,
        if (accessToken != null && accessToken.isNotEmpty)
          'accessToken': accessToken,
      };

      final response = await dio.post(
        ApiEndpoints.googleLogin,
        data: payload,
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final requiresVerification =
            data['requiresVerification'] as bool? ?? false;
        final requires2FA = data['requires2FA'] as bool? ?? false;

        if (requiresVerification ||
            requires2FA ||
            (token == null || token.isEmpty)) {
          return UserEntity(
            id: data['userUId'] ?? '',
            userUId: data['userUId'] ?? '',
            userName: data['userName'] ?? '',
            email: data['email'] ?? '',
            requiresVerification: requiresVerification,
            requires2FA: requires2FA,
          );
        }

        return UserEntity(
          id: data['userUId'] ?? '',
          userUId: data['userUId'] ?? '',
          userName: data['userName'] ?? '',
          email: data['email'] ?? '',
          token: token,
          refreshToken: refreshToken,
        );
      }
      throw Exception("Đăng nhập Google không thành công");
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = "Lỗi kết nối Server";
      if (data is Map) {
        errorMsg = data['message'] ?? errorMsg;
      } else if (data is String) {
        errorMsg = data.trim();
      }
      throw Exception(errorMsg);
    }
  }

  @override
  Future<void> logout({required String userUId}) async {
    try {
      await dio.post('${ApiEndpoints.logout}?userUId=$userUId');
    } on DioException {
      // Vẫn tiếp tục logout cục bộ dù API thất bại
    }
  }

  @override
  Future<UserEntity> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyCode,
        data: {'email': email, 'code': code},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        // Backend trả về token sau khi xác thực thành công
        final token = data is Map
            ? data['accessToken'] as String? ?? data['token'] as String?
            : null;
        final refreshToken = data is Map
            ? data['refreshToken'] as String?
            : null;
        final userUId = data is Map ? data['userUId'] as String? ?? '' : '';
        final userName = data is Map ? data['userName'] as String? ?? '' : '';
        return UserEntity(
          id: userUId,
          userUId: userUId,
          userName: userName,
          email: email,
          token: token,
          refreshToken: refreshToken,
        );
      }
      throw Exception("Xác thực thất bại");
    } on DioException catch (e) {
      // BE trả lỗi dạng string plain text hoặc object
      final rawData = e.response?.data;
      String errorMsg;
      if (rawData is String) {
        errorMsg = rawData.trim();
      } else if (rawData is Map) {
        errorMsg = rawData['message'] ?? "Mã xác thực không hợp lệ";
      } else {
        errorMsg = "Lỗi kết nối Server";
      }
      throw Exception(errorMsg);
    }
  }

  @override
  Future<void> resendCode({required String email}) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.resendCode}?email=${Uri.encodeComponent(email)}',
      );
      if (response.statusCode != 200) {
        throw Exception("Không thể gửi lại mã");
      }
    } on DioException catch (e) {
      final rawData = e.response?.data;
      String errorMsg;
      if (rawData is String) {
        errorMsg = rawData.trim();
      } else if (rawData is Map) {
        errorMsg = rawData['message'] ?? "Không thể gửi lại mã";
      } else {
        errorMsg = "Lỗi kết nối Server";
      }
      throw Exception(errorMsg);
    }
  }

  @override
  Future<int> checkOtpStatus({required String email}) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.checkOtpStatus}?email=${Uri.encodeComponent(email)}',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['expiresInSeconds'] ?? 0;
      }
      return 0;
    } on DioException {
      return 0;
    }
  }
}
