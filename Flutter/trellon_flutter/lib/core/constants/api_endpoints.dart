class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:5293/v1/api';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String verifyCode = '/users/verify-code';
  static const String resendCode = '/users/resend-code';
  static const String userInbox='/user-inbox';
  static const String card = '/cards';
}
