import 'package:apptreolon/features/profile/presentation/pages/change_pass_page.dart';
import 'package:apptreolon/features/profile/presentation/pages/enable_2fa_screen.dart';
import 'package:apptreolon/features/profile/presentation/pages/profile_page.dart';
import 'package:apptreolon/features/profile/presentation/pages/security_page.dart';
import 'package:flutter/material.dart';
import 'core/common_widgets/main_shell.dart';
import 'features/board/presentation/pages/board_detail_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/two_factor_auth_page.dart';
import 'features/auth/presentation/pages/verify_page.dart';
import 'features/board/presentation/pages/workspace_menu_page.dart';

class AppRoutes {
  static const String home           = '/home';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String verify         = '/verify';
  static const String boardDetail    = '/board-detail';
  static const String workspaceMenu  = '/workspace-menu';
  static const String cardDetail     = '/card-detail';
  static const String userProfile    = '/user-profile';
  static const String securityPage   = '/security';
  static const String changePassPage   = '/change-password';
  static const String enable2FA      = '/enable-2fa';
  static const String twoFactorAuthPage = '/two-factor-auth';
  

  static Map<String, WidgetBuilder> routes = {
    login:         (context) => const LoginPage(),
    register:      (context) => const RegisterPage(),
    verify:        (context) => const VerifyPage(),
    home:          (context) => const MainShell(),
    boardDetail:   (context) => const BoardDetailPage(),
    workspaceMenu: (context) => const WorkspaceMenuPage(),
    userProfile:   (context) => const ProfilePage(),
    securityPage:  (context) => const SecurityPage(),
    changePassPage: (context) => ChangePassword(),
    enable2FA:     (context) => const Enable2FAScreen(),
    twoFactorAuthPage: (context) => const TwoFactorAuthPage(),
  };
}
