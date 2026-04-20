class ApiEndpoints {
  static const String baseUrl = 'http://192.168.1.6:5293/v1/api/';
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String refreshToken = 'auth/refresh-token';
  static const String logout = 'auth/logout';
  static const String verifyCode = 'users/verify-code';
  static const String resendCode = 'users/resend-code';
  static const String checkOtpStatus = 'users/get-verification-status';
  static const String userInbox='user-inbox';
  static const String card = 'cards';
  static const String comments = 'comments';
  static const String cardMember = 'CardMember';
  static const String todoItem = 'todoItem';
  static const String lists = 'lists';
  static const String boards = 'boards';
  static const String workspace = 'workspace';
  static const String recentBoards = 'RecentBoard';
  static const String workspaceMember = 'workspaceMember';
}
