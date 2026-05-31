import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String userName,
    required String email,
    required String password,
  });

  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> googleLogin({
    required String idToken,
    String? accessToken,
  });

  Future<void> logout({required String userUId});

  Future<UserEntity> verifyCode({required String email, required String code});

  Future<void> resendCode({required String email});

  Future<int> checkOtpStatus({required String email});
}
