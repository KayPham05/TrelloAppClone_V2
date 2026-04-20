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
import '../widgets/board_detail_top_bar.dart';
import '../widgets/list_menu_bottom_sheet.dart';
import '../widgets/zoom_controls_widget.dart';

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  bool _isStarred = false;

  // ── Zoom toggle ────────────────────────────────────────────────────────────
  bool _isDetailMode = false; // true = detail (1x), false = overview (thu nhỏ)
  
  // Tỉ lệ scale cho chế độ zoom
  double get _s => _isDetailMode ? 1.0 : 0.65;
  
  List<ListEntity>? _localLists;

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
                    BlocConsumer<BoardDetailCubit, BoardDetailState>(
                      listenWhen: (prev, curr) {
                        return curr is BoardDetailLoaded;
                      },
                      listener: (ctx, state) {
                        if (state is BoardDetailLoaded) {
                          if (state.transientError != null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(state.transientError!)),
                            );
                            _cubit?.clearTransientError();
                          }
                          setState(() {
                            _localLists = List.from(state.lists);
                          });
                        }
                      },
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
                      child: ZoomControlsWidget(
                        isDetailMode: _isDetailMode,
                        onToggleZoom: _toggleZoom,
                      ),
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

  // ── Board Area (ReorderableListView chiều ngang) ───────────────────────────
  Widget _buildBoardArea(BoardDetailLoaded state) {
    final listsToRender = _localLists ?? state.lists;
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(16 * _s, 16 * _s, 16 * _s, 120),
      buildDefaultDragHandles: false,
      // Giảm tốc độ auto-scroll khi drag gần edge
      autoScrollerVelocityScalar: 2.0,
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
      itemCount: listsToRender.length,
      itemBuilder: (context, index) {
        final list = listsToRender[index];
        return Align(
          key: ValueKey(list.id),
          alignment: Alignment.topCenter, // Căn lên đỉnh – không stretch hết chiều cao
          child: Container(
            margin: EdgeInsets.only(right: 16 * _s),
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
        final list = listsToRender[oldIndex];
        
        setState(() {
          final item = _localLists!.removeAt(oldIndex);
          _localLists!.insert(targetIdx, item);
        });
        
        _cubit?.moveList(list: list, insertIndex: targetIdx);
      },
    );
  }

  // ── Column UI ──────────────────────────────────────────────────────────────
  Widget _buildColumnUI(ListEntity list, int columnIndex, String boardId) {
    final double colWidth = 280.0 * _s;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: colWidth,
      // KHÔNG set height cứng – để Column tự tính, shrink theo số card
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12 * _s),
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
          // ── Cards: dùng shrinkWrap, CÓ dùng Flexible để cuộn mượt ──
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
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
      padding: EdgeInsets.fromLTRB(14 * _s, 14 * _s, 8 * _s, 10 * _s),
      child: Row(
        children: [
          Expanded(
            child: Text(
              list.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 13 * _s,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: 0.8 * _s,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.surfaceContainerLow,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => ListMenuBottomSheet(list: list),
              );
            },
            child: Icon(
              Icons.more_horiz_rounded,
              size: 22 * _s,
              color: AppColors.onSurfaceVariant,
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
        
        // Cập nhật ngay, loại bỏ delay frame
        _cubit?.moveCard(
          card: card,
          sourceListId: sourceListId,
          targetListId: targetListId,
          insertIndex: targetIdx,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final double slotHeightNormal = 8.0 * _s; 
        final double slotHeightHovered = 52.0 * _s;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: isHovered ? slotHeightHovered : slotHeightNormal,
          margin: EdgeInsets.symmetric(horizontal: 8 * _s),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8 * _s),
            border: isHovered
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    width: 1.5 * _s,
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
    final double cardWidth = 264.0 * _s;
    
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
      onDragEnd: (details) => _onDragEnd(),
      onDraggableCanceled: (velocity, offset) => _onDragEnd(),
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
        height: 52 * _s,
        margin: EdgeInsets.fromLTRB(8 * _s, 0, 8 * _s, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8 * _s),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5 * _s,
          ),
        ),
      ),
      child: _buildCardUI(card),
    );
  }

  Widget _buildCardUI(CardEntity card, {bool elevated = false}) {
    // Dùng _s để scale đều mọi thứ
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/card-detail'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.fromLTRB(8 * _s, 0, 8 * _s, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8 * _s),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 14 * _s,
                    offset: Offset(0, 6 * _s),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0x0F191C1E),
                    blurRadius: 4 * _s,
                    offset: Offset(0, 2 * _s),
                  ),
                ],
        ),
        padding: EdgeInsets.all(12 * _s),
        child: Text(
          card.title,
          style: GoogleFonts.inter(
            fontSize: 14.0 * _s,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
            height: 1.35,
          ),
          maxLines: null,
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
        margin: EdgeInsets.fromLTRB(8 * _s, 4 * _s, 8 * _s, 8 * _s),
        padding: EdgeInsets.symmetric(horizontal: 10 * _s, vertical: 8 * _s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * _s),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(Icons.add_rounded,
                size: 18 * _s, color: AppColors.onSurfaceVariant),
            SizedBox(width: 6 * _s),
            Text(
              'Thêm thẻ',
              style: GoogleFonts.inter(
                fontSize: 13 * _s,
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
                  BoardDetailTopBarWidget(
                    boardName: boardName,
                    onMorePressed: () => _showMoreOptions(context),
                  ),
                  Expanded(child: _buildBody(state)),
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
      onTap: () => setState(() => _isAddingList = true),
      child: Container(
        width: 200 * _s,
        margin: EdgeInsets.only(left: 8 * _s),
        padding: EdgeInsets.symmetric(horizontal: 14 * _s, vertical: 12 * _s),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12 * _s),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), width: 1 * _s),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18 * _s),
            SizedBox(width: 6 * _s),
            Text(
              'Thêm cột mới',
              style: GoogleFonts.inter(
                fontSize: 13 * _s,
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
