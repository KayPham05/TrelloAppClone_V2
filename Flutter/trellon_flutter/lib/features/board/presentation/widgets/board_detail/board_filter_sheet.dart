import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../init_dependencies.dart';
import '../../../data/datasources/board_remote_data_source.dart';
import '../../../domain/entities/list_entity.dart';
import '../../cubit/board_filter_cubit.dart';
import '../../cubit/board_member_cubit.dart';
import '../../../../card/domain/entities/card_entity.dart';

/// Bottom sheet for advanced board filter.
///
/// Caller should provide [lists] (current board lists) so the sheet can show
/// live match counts and allow the user to confirm, returning the filtered lists.
class BoardFilterSheet extends StatefulWidget {
  final String boardId;
  final List<ListEntity> lists;

  const BoardFilterSheet({
    super.key,
    required this.boardId,
    required this.lists,
  });

  /// Convenience: show the sheet and return filtered lists (or null on dismiss).
  static Future<List<ListEntity>?> show(
    BuildContext context, {
    required String boardId,
    required List<ListEntity> lists,
    BoardFilterCubit? existingCubit,
  }) {
    return showModalBottomSheet<List<ListEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 215, 205, 205),
      builder: (_) => BoardFilterSheet(boardId: boardId, lists: lists),
    );
  }

  @override
  State<BoardFilterSheet> createState() => _BoardFilterSheetState();
}

class _BoardFilterSheetState extends State<BoardFilterSheet> {
  final _queryCtrl = TextEditingController();
  final _filterCubit = BoardFilterCubit();
  final _focusNode = FocusNode();

  // Which quick-hashtag section is currently expanded
  _QuickSection? _expandedSection;

  @override
  void dispose() {
    _queryCtrl.dispose();
    _filterCubit.close();
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalCards =>
      widget.lists.fold<int>(0, (s, l) => s + l.cards.length);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _filterCubit,
      child: BlocProvider(
        create: (_) => BoardMemberCubit(
          dataSource: serviceLocator<BoardRemoteDataSource>(),
          userLocalDataSource: serviceLocator<UserLocalDataSource>(),
        )..loadMembers(widget.boardId),
        child: _buildSheet(),
      ),
    );
  }

  Widget _buildSheet() {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocBuilder<BoardFilterCubit, BoardFilterState>(
        bloc: _filterCubit,
        builder: (context, filterState) {
          final filteredLists = _filterCubit.applyFilter(widget.lists);
          final matchCount = _filterCubit.countMatches(widget.lists);

          return Column(
            children: [
              _buildHandle(),
              _buildSearchBar(filterState),
              _buildCountRow(matchCount, filterState),
              const Divider(color: Color(0xFF2D3447), height: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickHashtagRow(filterState),
                      if (_expandedSection == _QuickSection.member)
                        _buildMemberSection(filterState),
                      if (_expandedSection == _QuickSection.label)
                        _buildLabelSection(filterState),
                      if (_expandedSection == _QuickSection.dueDate)
                        _buildDueDateSection(filterState),
                      if (filterState.isActive)
                        _buildActiveFiltersChips(filterState),
                      const SizedBox(height: 8),
                      if (filterState.isActive)
                        _buildFilteredPreview(filteredLists),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(filteredLists, filterState),
            ],
          );
        },
      ),
    );
  }

  // ── Handle bar ──────────────────────────────────────────────────────────────
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BoardFilterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 254, 254, 254),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.query.isNotEmpty
                      ? AppColors.blueLight
                      : Colors.white12,
                ),
              ),
              child: TextField(
                controller: _queryCtrl,
                focusNode: _focusNode,
                style: GoogleFonts.inter(
                  color: const Color.fromARGB(255, 19, 19, 19),
                  fontSize: 15,
                ),
                cursorColor: AppColors.blueLight,
                decoration: InputDecoration(
                  hintText: 'Lọc thẻ...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 20,
                  ),
                  suffixIcon: state.query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () {
                            _queryCtrl.clear();
                            _filterCubit.setQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _filterCubit.setQuery,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF252B3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Count row ────────────────────────────────────────────────────────────────
  Widget _buildCountRow(int matchCount, BoardFilterState state) {
    final label = state.isActive
        ? (matchCount == 0 ? '0 thẻ sẽ trùng khớp' : '$matchCount thẻ')
        : '$_totalCards thẻ';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
          ),
          const Spacer(),
          if (state.isActive)
            GestureDetector(
              onTap: () {
                _queryCtrl.clear();
                _filterCubit.clearAll();
                setState(() => _expandedSection = null);
              },
              child: Text(
                'Xóa bộ lọc',
                style: GoogleFonts.inter(
                  color: AppColors.blueLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Quick hashtag row ────────────────────────────────────────────────────────
  Widget _buildQuickHashtagRow(BoardFilterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _QuickBtn(
            icon: Icons.alternate_email,
            label: '@',
            active:
                _expandedSection == _QuickSection.member ||
                state.selectedMemberUIds.isNotEmpty,
            badgeCount: state.selectedMemberUIds.length,
            onTap: () => setState(() {
              _expandedSection = _expandedSection == _QuickSection.member
                  ? null
                  : _QuickSection.member;
              _focusNode.unfocus();
            }),
          ),
          const SizedBox(width: 8),
          _QuickBtn(
            icon: Icons.label_outline,
            label: 'Nhãn',
            active:
                _expandedSection == _QuickSection.label ||
                state.selectedLabelIds.isNotEmpty,
            badgeCount: state.selectedLabelIds.length,
            onTap: () => setState(() {
              _expandedSection = _expandedSection == _QuickSection.label
                  ? null
                  : _QuickSection.label;
              _focusNode.unfocus();
            }),
          ),
          const SizedBox(width: 8),
          _QuickBtn(
            icon: Icons.access_time,
            label: 'Hết hạn',
            active:
                _expandedSection == _QuickSection.dueDate ||
                state.dueDateFilter != DueDateFilter.none,
            onTap: () => setState(() {
              _expandedSection = _expandedSection == _QuickSection.dueDate
                  ? null
                  : _QuickSection.dueDate;
              _focusNode.unfocus();
            }),
          ),
        ],
      ),
    );
  }

  // ── Member section ───────────────────────────────────────────────────────────
  Widget _buildMemberSection(BoardFilterState filterState) {
    return BlocBuilder<BoardMemberCubit, BoardMemberState>(
      builder: (ctx, memberState) {
        if (memberState is BoardMemberLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (memberState is! BoardMemberLoaded) return const SizedBox.shrink();

        final members = memberState.members;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Thành viên trong bảng',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final m = members[i];
                  final selected = filterState.selectedMemberUIds.contains(
                    m.userUId,
                  );
                  return GestureDetector(
                    onTap: () => _filterCubit.toggleMember(m.userUId),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.blueLight
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: CachedNetworkImageProvider(
                                  m.resolvedAvatarUrl,
                                  cacheKey: 'av_${m.userUId}',
                                ),
                              ),
                              if (selected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppColors.blueLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            m.userName.split(' ').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: selected ? Colors.white : Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // ── Label section ────────────────────────────────────────────────────────────
  Widget _buildLabelSection(BoardFilterState filterState) {
    // Collect all unique labels from all cards
    final labelMap = <String, CardLabelEntity>{};
    for (final list in widget.lists) {
      for (final card in list.cards) {
        for (final label in card.labels) {
          labelMap[label.id] = label;
        }
      }
    }
    final labels = labelMap.values.toList();

    if (labels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Không có nhãn nào trong bảng này.',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhãn',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: labels.map((label) {
              final selected = filterState.selectedLabelIds.contains(label.id);
              Color? parsed;
              try {
                final hex = label.colorCode.replaceFirst('#', '');
                parsed = Color(int.parse('FF$hex', radix: 16));
              } catch (_) {
                parsed = Colors.grey;
              }
              return GestureDetector(
                onTap: () => _filterCubit.toggleLabel(label.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: parsed.withValues(alpha: selected ? 1.0 : 0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    label.title.isNotEmpty ? label.title : 'Nhãn',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Due-date section ─────────────────────────────────────────────────────────
  Widget _buildDueDateSection(BoardFilterState filterState) {
    const options = [
      DueDateFilter.overdue,
      DueDateFilter.today,
      DueDateFilter.thisWeek,
      DueDateFilter.thisMonth,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hết hạn',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final selected = filterState.dueDateFilter == opt;
              return GestureDetector(
                onTap: () => _filterCubit.setDueDate(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? (opt == DueDateFilter.overdue
                              ? AppColors.error.withValues(alpha: 0.85)
                              : AppColors.blueLight.withValues(alpha: 0.85))
                        : const Color(0xFF252B3A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? Colors.white30 : Colors.white12,
                    ),
                  ),
                  child: Text(
                    opt.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Active filter chips ──────────────────────────────────────────────────────
  Widget _buildActiveFiltersChips(BoardFilterState state) {
    final chips = <Widget>[];

    if (state.query.isNotEmpty) {
      chips.add(
        _ActiveChip(
          label: '"${state.query}"',
          onRemove: () {
            _queryCtrl.clear();
            _filterCubit.setQuery('');
          },
        ),
      );
    }
    if (state.dueDateFilter != DueDateFilter.none) {
      chips.add(
        _ActiveChip(
          label: state.dueDateFilter.label,
          onRemove: () => _filterCubit.setDueDate(state.dueDateFilter),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(spacing: 8, runSpacing: 4, children: chips),
    );
  }

  // ── Filtered preview ─────────────────────────────────────────────────────────
  Widget _buildFilteredPreview(List<ListEntity> filteredLists) {
    final totalMatch = filteredLists.fold<int>(0, (s, l) => s + l.cards.length);
    if (totalMatch == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả lọc',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...filteredLists
              .where((l) => l.cards.isNotEmpty)
              .map((l) => _PreviewListTile(list: l)),
        ],
      ),
    );
  }

  // ── Bottom actions ────────────────────────────────────────────────────────────
  Widget _buildBottomActions(
    List<ListEntity> filteredLists,
    BoardFilterState state,
  ) {
    final matchCount = filteredLists.fold<int>(0, (s, l) => s + l.cards.length);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2D3447))),
      ),
      child: Row(
        children: [
          if (state.isActive)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _queryCtrl.clear();
                  _filterCubit.clearAll();
                  setState(() => _expandedSection = null);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Xóa bộ lọc', style: GoogleFonts.inter()),
              ),
            ),
          if (state.isActive) const SizedBox(width: 12),
          Expanded(
            flex: state.isActive ? 2 : 1,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, filteredLists),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                state.isActive ? 'Tìm kiếm ($matchCount thẻ)' : 'Đóng',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

enum _QuickSection { member, label, dueDate }

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int badgeCount;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.blueLight.withValues(alpha: 0.2)
              : const Color(0xFF252B3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.blueLight : Colors.white12,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppColors.blueLight : Colors.white60,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: active ? AppColors.blueLight : Colors.white60,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blueLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blueLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.white54, size: 14),
          ),
        ],
      ),
    );
  }
}

class _PreviewListTile extends StatelessWidget {
  final ListEntity list;
  const _PreviewListTile({required this.list});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            list.name,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          ...list.cards.map(
            (card) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Colors.white38,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.title,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (card.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        _formatDue(card.dueDate!),
                        style: GoogleFonts.inter(
                          color: card.dueDate!.isBefore(DateTime.now())
                              ? AppColors.error
                              : Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDue(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
