import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class VerifyCodeUseCase {
  final AuthRepository repository;
  VerifyCodeUseCase(this.repository);

  Future<UserEntity> call({required String email, required String code}) =>
      repository.verifyCode(email: email, code: code);
}

class ResendCodeUseCase {
  final AuthRepository repository;
  ResendCodeUseCase(this.repository);

  Future<void> call({required String email}) =>
      repository.resendCode(email: email);
}

class CheckOtpStatusUseCase {
  final AuthRepository repository;
  CheckOtpStatusUseCase(this.repository);

  Future<int> call({required String email}) =>
      repository.checkOtpStatus(email: email);
}
