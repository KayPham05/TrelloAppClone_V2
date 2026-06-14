import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/board_entity.dart';
import '../cubit/board_cubit.dart';
import '../widgets/home_overview/home_app_bar_widget.dart';
import '../widgets/home_overview/home_board_grid_widget.dart';
import '../widgets/home_overview/home_section_header_widget.dart';
import '../widgets/home_overview/personal_board_tile_widget.dart';
import '../widgets/home_overview/guest_workspace_tile_widget.dart';
import '../widgets/home_overview/create_personal_board_sheet.dart';

class HomeOverviewPage extends StatefulWidget {
  const HomeOverviewPage({super.key});

  @override
  State<HomeOverviewPage> createState() => _HomeOverviewPageState();
}

class _HomeOverviewPageState extends State<HomeOverviewPage> {
  String _searchQuery = '';
  int _starredPage = 0;
  int _recentPage = 0;
  static const int _boardPageSize = 5;

  void _showCreateBoardBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePersonalBoardSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBarWidget(
              onSearchChanged: (query) => setState(() => _searchQuery = query),
            ),
            Expanded(
              child: BlocBuilder<BoardCubit, BoardState>(
                builder: (context, state) {
                  if (state is BoardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BoardError) {
                    return _buildError(state.message);
                  }
                  if (state is BoardLoaded) {
                    return _buildContent(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBoardBottomSheet,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BoardLoaded state) {
    final filteredPersonal = _searchQuery.isEmpty
        ? state.personalBoards
        : state.personalBoards
              .where(
                (b) =>
                    b.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    final filteredGuest = _searchQuery.isEmpty
        ? state.guestWorkspaces
        : state.guestWorkspaces
              .where(
                (w) =>
                    w.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (state.starredBoards.isNotEmpty && _searchQuery.isEmpty) ...[
                const HomeSectionHeaderWidget(
                  icon: Icons.star_rounded,
                  iconColor: Color(0xFFF59E0B),
                  title: 'Bảng gắn dấu sao',
                ),
                const SizedBox(height: 12),
                HomeBoardGridWidget(
                  boards: _pagedBoards(state.starredBoards, _starredPage),
                  isStarredGroup: true,
                  onCreateBoard: _showCreateBoardBottomSheet,
                ),
                _buildPager(
                  totalItems: state.starredBoards.length,
                  page: _starredPage,
                  onPageChanged: (page) => setState(() => _starredPage = page),
                ),
                const SizedBox(height: 28),
              ],

              // Recent boards (horizontal grid)
              if (state.recentBoards.isNotEmpty && _searchQuery.isEmpty) ...[
                const HomeSectionHeaderWidget(
                  icon: Icons.access_time_rounded,
                  iconColor: Color(0xFFF59E0B),
                  title: 'Truy cập gần đây',
                ),
                const SizedBox(height: 12),
                HomeBoardGridWidget(
                  boards: _pagedBoards(state.recentBoards, _recentPage),
                  isStarredGroup: true,
                  onCreateBoard: _showCreateBoardBottomSheet,
                ),
                _buildPager(
                  totalItems: state.recentBoards.length,
                  page: _recentPage,
                  onPageChanged: (page) => setState(() => _recentPage = page),
                ),
                const SizedBox(height: 28),
              ],

              // ── Personal boards section ──────────────────────────────────
              const HomeSectionHeaderWidget(
                icon: Icons.person_rounded,
                iconColor: AppColors.primary,
                title: 'Không gian làm việc của bạn',
              ),
              const SizedBox(height: 12),
              if (filteredPersonal.isEmpty && _searchQuery.isEmpty)
                _buildEmptyPersonal()
              else
                ...filteredPersonal.map(
                  (board) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PersonalBoardTileWidget(
                      board: board,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/board-detail',
                        arguments: board,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // ── Guest workspaces section ─────────────────────────────────
              const HomeSectionHeaderWidget(
                icon: Icons.group_rounded,
                iconColor: Color(0xFF22C55E),
                title: 'Không gian làm việc của khách',
              ),
              const SizedBox(height: 12),
              if (filteredGuest.isEmpty && _searchQuery.isEmpty)
                _buildEmptyGuest()
              else
                ...filteredGuest.map(
                  (ws) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GuestWorkspaceTileWidget(
                      workspace: ws,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/workspace-detail',
                        arguments: ws,
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  List<BoardEntity> _pagedBoards(List<BoardEntity> boards, int page) {
    final pageCount = boards.isEmpty
        ? 1
        : ((boards.length - 1) ~/ _boardPageSize) + 1;
    final safePage = page.clamp(0, pageCount - 1);
    final start = safePage * _boardPageSize;
    return boards.skip(start).take(_boardPageSize).toList();
  }

  Widget _buildPager({
    required int totalItems,
    required int page,
    required ValueChanged<int> onPageChanged,
  }) {
    if (totalItems <= _boardPageSize) return const SizedBox.shrink();

    final pageCount = ((totalItems - 1) ~/ _boardPageSize) + 1;
    final safePage = page.clamp(0, pageCount - 1);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: safePage == 0 ? null : () => onPageChanged(safePage - 1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${safePage + 1}/$pageCount',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: safePage >= pageCount - 1
                ? null
                : () => onPageChanged(safePage + 1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPersonal() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 40,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'Bạn chưa có bảng cá nhân nào',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn + để tạo bảng đầu tiên của bạn.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGuest() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 40,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'Bạn chưa được mời vào workspace nào',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(
        'Lỗi: $message',
        style: GoogleFonts.inter(color: AppColors.error),
      ),
    );
  }
}
