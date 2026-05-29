import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../domain/usecases/verify_code_usecase.dart';

part 'verify_state.dart';

class VerifyCubit extends Cubit<VerifyState> {
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResendCodeUseCase resendCodeUseCase;
  final CheckOtpStatusUseCase checkOtpStatusUseCase;

  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  VerifyCubit({
    required this.verifyCodeUseCase,
    required this.resendCodeUseCase,
    required this.checkOtpStatusUseCase,
  }) : super(VerifyInitial());

  Future<void> checkOtpStatus(String email) async {
    // Khóa nút Gửi lại mã ngay lập tức bằng cách set timer 30s
    startCountdown(seconds: 30);
    try {
      final remainingSeconds = await checkOtpStatusUseCase(email: email);
      if (remainingSeconds > 0) {
        startCountdown(seconds: remainingSeconds);
      } else {
        // Nếu backend trả về 0 (hoặc lỗi), nó đã tự động gửi lại mã rồi,
        // nên chúng ta bắt đầu countdown mới 30s
        startCountdown(seconds: 30);
      }
    } catch (e) {
      // Bỏ qua lỗi check status để không làm phiền UX quá mức
      startCountdown(seconds: 0);
    }
  }

  /// Bắt đầu đếm ngược sau khi mã được gửi lần đầu
  void startCountdown({int seconds = 30}) {
    _secondsRemaining = seconds;
    
    // Emit ngay lập tức để giao diện cập nhật và khóa nút
    if (_secondsRemaining > 0) {
      emit(VerifyCountdown(_secondsRemaining));
    } else {
      emit(VerifyCountdownDone());
    }

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
      final user = await verifyCodeUseCase(email: email, code: code);
      _countdownTimer?.cancel();

      // Lưu session nếu backend trả về token (xác thực email sau đăng ký)
      if (user.token != null && user.token!.isNotEmpty) {
        final secureStorage = const FlutterSecureStorage();
        await secureStorage.write(key: 'access_token', value: user.token!);
        await secureStorage.write(
          key: 'refresh_token',
          value: user.refreshToken ?? '',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLogged', true);
        await prefs.setString('user_uid', user.userUId ?? '');
        await prefs.setString('user_name', user.userName);
        await prefs.setString('user_email', user.email);
        await prefs.setBool('is_two_factor_enabled', false);
      }

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
