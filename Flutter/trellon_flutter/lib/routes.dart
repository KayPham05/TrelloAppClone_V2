import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/common_widgets/main_shell.dart';
import 'features/board/presentation/pages/board_detail_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/verify_page.dart';
import 'features/introduction/presentation/pages/introduction_page.dart';
import 'features/workspace/presentation/pages/workspace_menu_page.dart';
import 'features/workspace/domain/entities/workspace_entity.dart';
import 'features/workspace/presentation/cubit/workspace_cubit.dart';
import 'features/board/presentation/cubit/board_cubit.dart';
import 'features/board/presentation/cubit/board_detail_cubit.dart';
import 'features/card/presentation/pages/card_detail_page.dart';
import 'features/card/domain/entities/card_entity.dart';
import 'init_dependencies.dart';

class AppRoutes {
  static const String home           = '/home';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String verify         = '/verify';
  static const String boardDetail    = '/board-detail';
  static const String workspaceMenu  = '/workspace-menu';
  static const String workspaceDetail = '/workspace-detail';
  static const String introduction   = '/introduction';
  static const String cardDetail      = '/card-detail';

  static Map<String, WidgetBuilder> routes = {
    login:         (context) => const LoginPage(),
    register:      (context) => const RegisterPage(),
    verify:        (context) => const VerifyPage(),
    home:          (context) => const MainShell(),
    introduction:  (context) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<WorkspaceCubit>()),
        BlocProvider(create: (_) => serviceLocator<BoardCubit>()),
      ],
      child: const IntroductionPage(),
    ),
    boardDetail: (context) => BlocProvider(
      create: (_) => serviceLocator<BoardDetailCubit>(),
      child: const BoardDetailPage(),
    ),
    workspaceMenu: (context) => _buildWorkspaceMenu(context),
    workspaceDetail: (context) => _buildWorkspaceMenu(context),
    cardDetail: (context) => _buildCardDetail(context),
  };

  static Widget _buildWorkspaceMenu(BuildContext context) {
    final workspace = ModalRoute.of(context)?.settings.arguments as WorkspaceEntity?;
    if (workspace == null) {
      return const Scaffold(body: Center(child: Text('Workspace not provided')));
    }
    return BlocProvider(
      create: (_) => serviceLocator<WorkspaceCubit>(),
      child: WorkspaceMenuPage(workspace: workspace),
    );
  }

  static Widget _buildCardDetail(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    CardEntity? card;
    String? boardId;

    if (args is CardEntity) {
      card = args;
    } else if (args is Map<String, dynamic>) {
      card = args['card'] as CardEntity?;
      boardId = args['boardId'] as String?;
    }

    if (card == null) {
      return const Scaffold(body: Center(child: Text('Card not provided')));
    }

    return CardDetailPage(card: card, boardId: boardId);
  }
}
