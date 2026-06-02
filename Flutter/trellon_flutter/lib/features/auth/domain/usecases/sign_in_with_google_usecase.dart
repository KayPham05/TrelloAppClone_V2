import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity> call() async {
    return await repository.signInWithGoogle();
  }
}
