import '../repositories/i_auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return await repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
