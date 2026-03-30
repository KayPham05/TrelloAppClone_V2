part of 'verify_cubit.dart';

abstract class VerifyState {}

class VerifyInitial extends VerifyState {}

class VerifyLoading extends VerifyState {}

class VerifySuccess extends VerifyState {}

class VerifyError extends VerifyState {
  final String message;
  VerifyError(this.message);
}

class ResendLoading extends VerifyState {}

class ResendSuccess extends VerifyState {}

class VerifyCountdown extends VerifyState {
  final int seconds;
  VerifyCountdown(this.seconds);
}

class VerifyCountdownDone extends VerifyState {}
