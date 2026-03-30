import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../domain/usecases/verify_code_usecase.dart';

part 'verify_state.dart';

class VerifyCubit extends Cubit<VerifyState> {
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResendCodeUseCase resendCodeUseCase;

  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  VerifyCubit({
    required this.verifyCodeUseCase,
    required this.resendCodeUseCase,
  }) : super(VerifyInitial());

  /// Bắt đầu đếm ngược sau khi mã được gửi lần đầu
  void startCountdown({int seconds = 60}) {
    _secondsRemaining = seconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        emit(VerifyCountdownDone());
      } else {
        _secondsRemaining--;
        emit(VerifyCountdown(_secondsRemaining));
      }
    });
  }

  Future<void> verify({required String email, required String code}) async {
    emit(VerifyLoading());
    try {
      await verifyCodeUseCase(email: email, code: code);
      _countdownTimer?.cancel();
      emit(VerifySuccess());
    } catch (e) {
      emit(VerifyError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> resend({required String email}) async {
    emit(ResendLoading());
    try {
      await resendCodeUseCase(email: email);
      emit(ResendSuccess());
      startCountdown();
    } catch (e) {
      emit(VerifyError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
