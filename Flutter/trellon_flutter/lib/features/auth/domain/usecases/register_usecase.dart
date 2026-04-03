import '../repositories/i_auth_repository.dart';
import '../entities/user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String userName,
    required String email,
    required String password,
  }) async {
    return await repository.register(
      userName: userName,
      email: email,
      password: password,
    );
  }
}
