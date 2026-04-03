import 'package:flutter/material.dart';
import 'core/common_widgets/main_shell.dart';
import 'features/board/presentation/pages/board_detail_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/verify_page.dart';
import 'features/card/presentation/pages/card_detail_page.dart';
import 'features/board/presentation/pages/workspace_menu_page.dart';

class AppRoutes {
  static const String home           = '/home';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String verify         = '/verify';
  static const String boardDetail    = '/board-detail';
  static const String workspaceMenu  = '/workspace-menu';
  static const String cardDetail     = '/card-detail';

  static Map<String, WidgetBuilder> routes = {
    login:         (context) => const LoginPage(),
    register:      (context) => const RegisterPage(),
    verify:        (context) => const VerifyPage(),
    home:          (context) => const MainShell(),
    boardDetail:   (context) => const BoardDetailPage(),
    cardDetail:    (context) => const CardDetailPage(),
    workspaceMenu: (context) => const WorkspaceMenuPage(),
  };
}
