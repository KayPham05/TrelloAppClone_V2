import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordCubit({
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(ForgotPasswordInitial());

  Future<void> sendOtp({required String email}) async {
    emit(ForgotPasswordLoading());
    try {
      await forgotPasswordUseCase(email: email);
      emit(ForgotPasswordOtpSent(email));
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    emit(ForgotPasswordLoading());
    try {
      await resetPasswordUseCase(email: email, otp: otp, newPassword: newPassword);
      emit(ForgotPasswordResetSuccess(email));
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
