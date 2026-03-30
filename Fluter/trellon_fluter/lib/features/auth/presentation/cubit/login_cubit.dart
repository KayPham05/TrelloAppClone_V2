import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(email: email, password: password);

      // Email chưa được xác thực
      if (user.requiresVerification) {
        emit(LoginRequiresVerification(user.email));
        return;
      }

      // Lưu access_token và userUId vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', user.token ?? '');
      await prefs.setString('user_uid', user.userUId ?? '');

      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
