import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl => dotenv.env['API_URL']!;
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String refreshToken = 'auth/refresh-token';
  static const String logout = 'auth/logout';
  static const String verifyCode = 'users/verify-code';
  static const String resendCode = 'users/resend-code';
  static const String checkOtpStatus = 'users/get-verification-status';
  static const String userInbox = 'user-inbox';
  static const String card = 'cards';
  static const String comments = 'comments';
  static const String cardMember = 'CardMember';
  static const String todoItem = 'todoItem';
  static const String lists = 'lists';
  static const String boards = 'boards';
  static const String workspace = 'workspace';
  static const String recentBoards = 'RecentBoard';
  static const String workspaceMember = 'workspaceMember';
  static const String boardMember = 'boardMember';
  static const String notifications = 'notifications';
  static const String search = 'search';
  static const String googleLogin = 'auth/Google-login';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String analysis = 'analysis';
  // 2FA TOTP
  static const String twoFASetup = '/auth/2fa/setup';
  static const String twoFAEnable = '/auth/2fa/enable';
  static const String verifyOtp = '/auth/verify-otp';
  static const String changePassword = 'users/change-password';
  static const String updateProfile = 'users/update-profile';
  static const String checkChangeEmail = 'users/check-change-email';
  static const String sendChangeEmailOtp = 'users/send-change-email-otp';
  static const String confirmChangeEmail = 'users/confirm-change-email';
}
