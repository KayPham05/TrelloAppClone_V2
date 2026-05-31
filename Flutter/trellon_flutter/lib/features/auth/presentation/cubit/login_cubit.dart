import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      await _handleLoginResult(user);
    } catch (e) {
      if (e.toString().contains('ACCOUNT_LOCKED|')) {
        final emailStr = e.toString().split('|').last;
        emit(LoginAccountLocked(emailStr));
      } else {
        emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      final account = await googleSignIn.signIn();

      if (account == null) {
        emit(LoginInitial());
        return;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      final accessToken = authentication.accessToken;

      if ((idToken == null || idToken.isEmpty) &&
          (accessToken == null || accessToken.isEmpty)) {
        emit(LoginError('Không thể lấy thông tin đăng nhập Google'));
        return;
      }

      final user = await loginUseCase.googleLogin(
        idToken: idToken ?? '',
        accessToken: accessToken,
      );

      await _handleLoginResult(user);
    } catch (e) {
      emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _handleLoginResult(UserEntity user) async {
    if (user.requiresVerification) {
      emit(LoginRequiresVerification(user.email));
      return;
    }

    if (user.requires2FA) {
      emit(LoginRequires2FA(user.userUId ?? '', user.email));
      return;
    }

    final secureStorage = const FlutterSecureStorage();
    await secureStorage.write(key: 'access_token', value: user.token ?? '');
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

    emit(LoginSuccess(user));
  }
}
