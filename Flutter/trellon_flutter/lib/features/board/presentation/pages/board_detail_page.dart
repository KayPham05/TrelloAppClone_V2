import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/list_entity.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../cubit/board_detail_cubit.dart';
import '../cubit/board_detail_state.dart';
import '../models/drag_data_models.dart';

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  bool _isStarred = false;

  // ── Zoom toggle ────────────────────────────────────────────────────────────
  bool _isDetailMode = true; // true = detail (1x), false = overview (thu nhỏ)

  // ── Cubit reference ────────────────────────────────────────────────────────
  BoardDetailCubit? _cubit;

  // ── Local drag state ───────────────────────────────────────────────────────
  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  final String _boardName = 'Phát triển sản phẩm 2024';
  final Color _boardColor = AppColors.primaryContainer;

  @override
  void dispose() {
    _isDragging.dispose();
    super.dispose();
  }

  void _onDragStart() => _isDragging.value = true;
  void _onDragEnd() => _isDragging.value = false;

  void _toggleZoom() {
    setState(() => _isDetailMode = !_isDetailMode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        _cubit = serviceLocator<BoardDetailCubit>()
          ..loadBoard('board_1', 'Phát triển sản phẩm 2024');
        return _cubit!;
      },
      child: Scaffold(
        backgroundColor: _boardColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(context),
              _buildBoardSubBar(),
              Expanded(
                child: Stack(
                  children: [
                    // ── Main board content ──────────────────────────────────
                    BlocBuilder<BoardDetailCubit, BoardDetailState>(
                      buildWhen: (prev, curr) {
                        if (prev is BoardDetailLoaded &&
                            curr is BoardDetailLoaded) {
                          return prev.lists != curr.lists;
                        }
                        return prev.runtimeType != curr.runtimeType;
                      },
                      builder: (ctx, state) {
                        if (state is BoardDetailLoading ||
                            state is BoardDetailInitial) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }
                        if (state is BoardDetailError) {
                          return Center(
                            child: Text(state.message,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }
                        if (state is BoardDetailLoaded) {
                          return _buildBoardArea(state);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // ── Zoom toggle button ──────────────────────────────────
                    Positioned(
                      right: 16,
                      bottom: 32,
                      child: _buildZoomButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Zoom button ────────────────────────────────────────────────────────────
  Widget _buildZoomButton() {
    return GestureDetector(
      onTap: _toggleZoom,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isDetailMode ? Icons.zoom_out_rounded : Icons.zoom_in_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              _isDetailMode ? 'Tổng quan' : 'Chi tiết',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Board Area (ReorderableListView chiều ngang) ───────────────────────────
  Widget _buildBoardArea(BoardDetailLoaded state) {
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      buildDefaultDragHandles: false,
      // Giảm tốc độ auto-scroll khi drag gần edge (mặc định quá nhanh)
      autoScrollerVelocityScalar: 30,
      proxyDecorator: (child, index, animation) {
        return Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.88,
            child: Transform.rotate(
              angle: 0.025,
              child: child,
            ),
          ),
        );
      },
      itemCount: state.lists.length,
      itemBuilder: (context, index) {
        final list = state.lists[index];
        return Align(
          key: ValueKey(list.id),
          alignment: Alignment.topCenter, // Căn lên đỉnh – không stretch hết chiều cao
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: RepaintBoundary(
              child: _buildColumnUI(list, index, state.boardId),
            ),
          ),
        );
      },
      footer: Align(
        alignment: Alignment.topCenter,
        child: _buildAddListButton(),
      ),
      onReorder: (oldIndex, newIndex) {
        int targetIdx = newIndex;
        if (oldIndex < newIndex) targetIdx--;
        final list = state.lists[oldIndex];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _cubit?.moveList(list: list, insertIndex: targetIdx);
        });
      },
    );
  }

  // ── Column UI ──────────────────────────────────────────────────────────────
  Widget _buildColumnUI(ListEntity list, int columnIndex, String boardId) {
    final double colWidth = _isDetailMode ? 280.0 : 160.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: colWidth,
      // KHÔNG set height cứng – để Column tự tính, shrink theo số card
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // ← Co theo nội dung
        children: [
          // ── Header: là Handle để kéo cột ──
          ReorderableDragStartListener(
            index: columnIndex,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: _buildColumnHeader(list),
            ),
          ),
          // ── Cards: dùng shrinkWrap, không dùng Flexible ──
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: list.cards.length * 2 + 1,
            itemBuilder: (_, index) {
              if (index % 2 == 0) {
                return _buildCardSlot(list.id, index ~/ 2);
              } else {
                return RepaintBoundary(
                  child: _buildDraggableCard(
                    list.cards[index ~/ 2],
                    list.id,
                    index ~/ 2,
                    boardId,
                  ),
                );
              }
            },
          ),
          // ── Add card button ──
          _buildAddCardButton(list.id),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(ListEntity list) {
    return Container(
      color: Colors.transparent, // Phải có background để bắt sự kiện drag kéo thả
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              list.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: _isDetailMode ? 11 : 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '${list.cards.length}',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Slot (N+1 dọc) ───────────────────────────────────────────────────
  Widget _buildCardSlot(String targetListId, int insertIndex) {
    return DragTarget<CardDragData>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data.sourceListId == targetListId) {
          if (data.initialPosition == insertIndex ||
              data.initialPosition == insertIndex - 1) {
            return false;
          }
        }
        return true;
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        final card = data.card;
        final sourceListId = data.sourceListId;
        
        int targetIdx = insertIndex;
        // Fix target index left-shift when dropping in the same list and below original
        if (sourceListId == targetListId && data.initialPosition < insertIndex) {
          targetIdx--;
        }
        
        // Delay emit đến sau frame hiện tại
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _cubit?.moveCard(
            card: card,
            sourceListId: sourceListId,
            targetListId: targetListId,
            insertIndex: targetIdx,
          );
        });
      },
      builder: (_, candidateData, __) {
        final isHovered = candidateData.isNotEmpty;
        final double slotHeightNormal = 8.0; 
        final double slotHeightHovered = _isDetailMode ? 52.0 : 28.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: isHovered ? slotHeightHovered : slotHeightNormal,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isHovered
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    width: 1.5,
                  )
                : null,
          ),
        );
      },
    );
  }

  // ── Draggable Card ─────────────────────────────────────────────────────────
  Widget _buildDraggableCard(
    CardEntity card,
    String sourceListId,
    int sourceIndex,
    String boardId,
  ) {
    final double cardWidth = _isDetailMode ? 264.0 : 144.0;
    
    return LongPressDraggable<CardDragData>(
      data: CardDragData(
        id: card.id,
        boardId: boardId,
        initialPosition: sourceIndex,
        sourceListId: sourceListId,
        card: card,
      ),
      delay: const Duration(milliseconds: 250),
      onDragStarted: _onDragStart,
      onDragEnd: (_) => _onDragEnd(),
      onDraggableCanceled: (_, __) => _onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(
          angle: 0.02,
          child: SizedBox(
            width: cardWidth,
            child: Opacity(
              opacity: 0.92,
              child: _buildCardUI(card, elevated: true),
            ),
          ),
        ),
      ),
      // Ghost placeholder khi đang kéo
      childWhenDragging: Container(
        height: _isDetailMode ? 52 : 28,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
      ),
      child: _buildCardUI(card),
    );
  }

  Widget _buildCardUI(CardEntity card, {bool elevated = false}) {
    // Khi overview: thu nhỏ font + padding nhưng vẫn hiển thị text (giống Trello Mobile)
    final double fontSize = _isDetailMode ? 13.0 : 10.5;
    final double paddingVal = _isDetailMode ? 10.0 : 6.0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/card-detail'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x0F191C1E),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        padding: EdgeInsets.all(paddingVal),
        // Luôn hiển thị text, chỉ thu nhỏ khi overview
        child: Text(
          card.title,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
            height: 1.35,
          ),
          maxLines: _isDetailMode ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildAddCardButton(String listId) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Thêm thẻ mới (chưa tích hợp backend)')),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            const Icon(Icons.add_rounded,
                size: 18, color: AppColors.onSurfaceVariant),
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
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1D4ED8)),
            onPressed: () => Navigator.pop(context),
          ),
          const Icon(Icons.grid_view_rounded, color: Color(0xFF1D4ED8), size: 22),
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
          color: AppColors.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(
          'JS',
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }

  // ── Board Sub-bar ──────────────────────────────────────────────────────────
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
          Container(
              width: 1,
              height: 20,
              color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
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
          _boardIconButton(Icons.filter_list_rounded),
          const SizedBox(width: 4),
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

  Widget _buildAddListButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm cột mới (chưa tích hợp backend)')),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), width: 1),
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
}
