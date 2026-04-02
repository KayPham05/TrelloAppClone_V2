import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String userName,
    required String email,
    required String password,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<void> logout({required String userUId});

  Future<void> verifyCode({
    required String email,
    required String code,
  });

  Future<void> resendCode({required String email});
}