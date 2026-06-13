import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/board_entity.dart';
import 'board_list_tile.dart';

class RecentBoardsSection extends StatefulWidget {
  final List<BoardEntity> boards;
  final String title;
  final IconData icon;
  final String emptyMessage;

  const RecentBoardsSection({
    super.key,
    required this.boards,
    this.title = 'Bảng Gần Đây',
    this.icon = Icons.access_time_rounded,
    this.emptyMessage = 'Chưa có bảng nào được truy cập gần đây.',
  });

  @override
  State<RecentBoardsSection> createState() => _RecentBoardsSectionState();
}

class _RecentBoardsSectionState extends State<RecentBoardsSection> {
  static const int _pageSize = 5;
  int _page = 0;

  int get _pageCount {
    if (widget.boards.isEmpty) return 1;
    return ((widget.boards.length - 1) ~/ _pageSize) + 1;
  }

  @override
  void didUpdateWidget(covariant RecentBoardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= _pageCount) {
      _page = _pageCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _page * _pageSize;
    final visibleBoards = widget.boards.skip(start).take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            child: _PagedBoardContent(
              key: ValueKey(
                'page-$_page-${visibleBoards.map((board) => board.id).join('-')}',
              ),
              boards: visibleBoards,
              emptyMessage: widget.emptyMessage,
            ),
          ),
        ),
        if (widget.boards.length > _pageSize)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _page == 0 ? null : () => setState(() => _page--),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  '${_page + 1}/$_pageCount',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _page >= _pageCount - 1
                      ? null
                      : () => setState(() => _page++),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _PagedBoardContent extends StatelessWidget {
  final List<BoardEntity> boards;
  final String emptyMessage;

  const _PagedBoardContent({
    super.key,
    required this.boards,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (boards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(
          emptyMessage,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: boards.map((board) => BoardListTile(board: board)).toList(),
    );
  }
}
