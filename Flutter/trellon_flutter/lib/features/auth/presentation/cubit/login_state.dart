part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user;
  LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

/// Trạng thái cần xác thực email trước khi vào app
class LoginRequiresVerification extends LoginState {
  final String email;
  LoginRequiresVerification(this.email);
}

class LoginAccountLocked extends LoginState {
  final String email;
  LoginAccountLocked(this.email);
}

class LoginRequires2FA extends LoginState {
  final String userUId;
  final String email;
  LoginRequires2FA(this.userUId, this.email);
}
