import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../init_dependencies.dart';
import '../cubit/board_cubit.dart';
import '../widgets/home_action_menu.dart';
import '../widgets/create_board_bottom_sheet.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../workspace/domain/entities/workspace_entity.dart';
import '../../domain/entities/board_entity.dart';

// Modular widgets
import '../widgets/board_list/recent_boards_section.dart';
import '../widgets/board_list/board_list_hints.dart';
import '../widgets/board_list/empty_team_workspace_hint.dart';
import '../widgets/board_list/create_workspace_sheet.dart';
import '../widgets/home_overview/personal_board_tile_widget.dart';
import '../widgets/home_overview/guest_workspace_tile_widget.dart';

class BoardListPage extends StatelessWidget {
  const BoardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = serviceLocator<BoardCubit>();
        _loadData(cubit);
        return cubit;
      },
      child: const _BoardListView(),
    );
  }

  Future<void> _loadData(BoardCubit cubit) async {
    final uid = await serviceLocator<UserLocalDataSource>().getUserId();
    if (uid != null && uid.isNotEmpty) {
      cubit.fetchBoardData(uid, '');
    }
  }
}

class _BoardListView extends StatefulWidget {
  const _BoardListView();

  @override
  State<_BoardListView> createState() => _BoardListViewState();
}

class _BoardListViewState extends State<_BoardListView> {
  final GlobalKey _fabKey = GlobalKey();

  void _openCreateBoard() {
    showCreateBoardBottomSheet(context);
  }

  void _onFabTap() {
    showHomeActionMenu(
      _fabKey.currentContext ?? context,
      onCreateBoard: _openCreateBoard,
    );
  }

  void _showCreateWorkspaceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WorkspaceCubit>(),
        child: const CreateWorkspaceSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BoardCubit, BoardState>(
      listener: (ctx, state) {
        if (state is BoardCreated) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Tạo bảng thành công!')),
          );
        }
        if (state is BoardError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                pinned: true,
                elevation: 0,
                titleSpacing: 16,
                title: Text(
                  'Workspace',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search_rounded,
                        color: AppColors.onSurfaceVariant),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      key: _fabKey,
                      onTap: _onFabTap,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                  builder: (ctx, wsState) {
                    return BlocBuilder<BoardCubit, BoardState>(
                      builder: (ctx2, boardState) {
                        final isLoading = boardState is BoardInitial ||
                            boardState is BoardLoading;
                        List<BoardEntity> recentBoards = [];
                        List<BoardEntity> personalBoards = [];
                        List<WorkspaceEntity> guestWs = [];

                        if (boardState is BoardLoaded) {
                          recentBoards = boardState.recentBoards;
                          personalBoards = boardState.personalBoards;
                          guestWs = boardState.guestWorkspaces;
                        }
                        if (wsState is WorkspaceLoaded) {
                          if (guestWs.isEmpty) guestWs = wsState.team;
                        }

                        if (isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecentBoardsSection(boards: recentBoards),
                            const SectionLabel(label: 'KHÔNG GIAN LÀM VIỆC CỦA BẠN'),
                            ...personalBoards.map((board) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  child: PersonalBoardTileWidget(
                                    board: board,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/board-detail',
                                      arguments: board,
                                    ),
                                  ),
                                )),
                            if (personalBoards.isEmpty)
                              EmptyBoardHint(onCreateBoard: _openCreateBoard),
                            const SizedBox(height: 8),
                            const SectionLabel(label: 'KHÔNG GIAN LÀM VIỆC CỦA KHÁCH'),
                            ...guestWs.map((ws) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  child: GuestWorkspaceTileWidget(
                                    workspace: ws,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/workspace-detail',
                                      arguments: ws,
                                    ),
                                  ),
                                )),
                            if (guestWs.isEmpty)
                              EmptyTeamWorkspaceHint(
                                  onCreate: _showCreateWorkspaceSheet),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
