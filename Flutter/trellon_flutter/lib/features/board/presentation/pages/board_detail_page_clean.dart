import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/list_entity.dart';
import '../../../card/domain/entities/card_entity.dart';

// [PHASE 1 REFACTOR]: Đã xoá toàn bộ Mock classes (_MockList, _MockCard, _MockLabel) 
// và _mockBoardData array. Chuyển sang sử dụng ListEntity và CardEntity.

class BoardDetailPageClean extends StatefulWidget {
  const BoardDetailPageClean({super.key});

  @override
  State<BoardDetailPageClean> createState() => _BoardDetailPageCleanState();
}

class _BoardDetailPageCleanState extends State<BoardDetailPageClean> {
  bool _isStarred = false;
  final ScrollController _boardScrollController = ScrollController();
  final int _lazyLoadStep = 2;
  int _visibleListCount = 0;
  bool _isLoadingMore = false;
  final String _boardName = 'Phát triển sản phẩm 2024';
  final Color _boardColor = AppColors.primaryContainer; // #0052CC
  
  // Tạm thời khởi tạo mảng data rỗng chờ kết nối Bloc ở Phase 2
  final List<ListEntity> _boardData = []; 

  @override
  void initState() {
    super.initState();
    _visibleListCount = math.min(_lazyLoadStep, _boardData.length);
    _boardScrollController.addListener(_onBoardScroll);
  }

  @override
  void dispose() {
    _boardScrollController
      ..removeListener(_onBoardScroll)
      ..dispose();
    super.dispose();
  }

  void _onBoardScroll() {
    if (!_boardScrollController.hasClients) return;
    if (_isLoadingMore) return;
    if (_visibleListCount >= _boardData.length) return;

    final position = _boardScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadMoreColumns();
    }
  }

  Future<void> _loadMoreColumns() async {
    if (_visibleListCount >= _boardData.length) return;
    setState(() => _isLoadingMore = true);

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    setState(() {
      _visibleListCount = math.min(
        _visibleListCount + _lazyLoadStep,
        _boardData.length,
      );
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _boardColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            _buildBoardSubBar(),
            Expanded(child: _buildKanbanColumns()),
          ],
        ),
      ),
    );
  }

  // ── Top Bar (shared with home) ──────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1D4ED8),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Icon(
            Icons.grid_view_rounded,
            color: Color(0xFF1D4ED8),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            'Workspace',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          _buildAvatarChip(),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildAvatarChip() {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 4),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'JS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Board Sub-bar ────────────────────────────────────────────────────────
  Widget _buildBoardSubBar() {
    return Container(
      color: _boardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _boardName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Vertical divider
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          // Favourite button
          GestureDetector(
            onTap: () => setState(() => _isStarred = !_isStarred),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isStarred
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Yêu thích',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter
          _boardIconButton(Icons.filter_list_rounded),
          const SizedBox(width: 4),
          // More
          _boardIconButton(Icons.more_horiz_rounded),
        ],
      ),
    );
  }

  Widget _boardIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Kanban Columns ────────────────────────────────────────────────────────
  Widget _buildKanbanColumns() {
    final hasMore = _visibleListCount < _boardData.length;
    final visibleColumns = _boardData
        .take(_visibleListCount)
        .toList(growable: false);

    return ListView.builder(
      controller: _boardScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: visibleColumns.length + (hasMore ? 2 : 1),
      itemBuilder: (context, index) {
        if (index < visibleColumns.length) {
          return RepaintBoundary(child: _buildColumn(visibleColumns[index]));
        }
        if (hasMore && index == visibleColumns.length) {
          return _buildLoadMoreIndicator();
        }
        if (hasMore && index == visibleColumns.length + 1) {
          return _buildAddListButton();
        }
        if (!hasMore && index == visibleColumns.length) {
          return _buildAddListButton();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildColumn(ListEntity list) {
    // Tạm thời null check vì CardEntity có thể khác MockCard
    final cards = list.cards ?? []; 
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    list.name?.toUpperCase() ?? 'UNNAMED',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${cards.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards in scrollable area
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return RepaintBoundary(child: _buildCard(cards[index]));
              },
            ),
          ),

          // "Add a card" at bottom
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm thẻ mới (chưa tích hợp backend)'),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Thêm thẻ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
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

  Widget _buildCard(CardEntity card) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/card-detail'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F191C1E),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.title ?? 'No title',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddListButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm cột mới (chưa tích hợp backend)')),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              'Thêm cột mới',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
      ),
    );
  }
}
