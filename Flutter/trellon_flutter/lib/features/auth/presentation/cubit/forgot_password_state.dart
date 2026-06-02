part of 'forgot_password_cubit.dart';

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String email;
  ForgotPasswordOtpSent(this.email);
}

class ForgotPasswordResetSuccess extends ForgotPasswordState {
  final String email;
  ForgotPasswordResetSuccess(this.email);
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError(this.message);
}
