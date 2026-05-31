import '../repositories/i_auth_repository.dart';
import '../entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }

  Future<UserEntity> googleLogin({
    required String idToken,
    String? accessToken,
  }) async {
    return await repository.googleLogin(
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
