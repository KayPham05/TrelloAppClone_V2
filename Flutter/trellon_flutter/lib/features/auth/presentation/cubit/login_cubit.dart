import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(email: email, password: password);

      // Email chưa được xác thực
      if (user.requiresVerification) {
        emit(LoginRequiresVerification(user.email));
        return;
      }

      // Yêu cầu 2FA
      if (user.requires2FA) {
        emit(LoginRequires2FA(user.userUId!, user.email));
        return;
      }

      // Lưu access_token và refresh_token vào FlutterSecureStorage
      const secureStorage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      await secureStorage.write(key: 'access_token', value: user.token ?? '');
      await secureStorage.write(
        key: 'refresh_token',
        value: user.refreshToken ?? '',
      );

      // Lưu isLogged và userUId vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogged', true);
      await prefs.setString('user_uid', user.userUId ?? '');
      await prefs.setString('user_name', user.userName);
      await prefs.setString('user_email', user.email);
      // 2FA: Khi login thành công mà không qua 2FA → user chưa bật 2FA
      await prefs.setBool('is_two_factor_enabled', false);

      emit(LoginSuccess(user));
    } catch (e) {
      if (e.toString().contains('ACCOUNT_LOCKED|')) {
        final emailStr = e.toString().split('|').last;
        emit(LoginAccountLocked(emailStr));
      } else {
        emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}
