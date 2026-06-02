import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/list_entity.dart';
import '../../domain/entities/board_entity.dart';
import '../cubit/board_detail_cubit.dart';
import '../cubit/board_detail_state.dart';
import '../widgets/board_detail/board_menu_sheet.dart';
import '../widgets/board_detail/board_kanban_add_list.dart';
import '../widgets/board_detail/board_kanban_card_ui_widget.dart';
import '../widgets/board_detail/board_kanban_card_wrapper.dart';
import '../widgets/board_detail/board_kanban_column_widget.dart';
import '../models/drag_data_models.dart';
import '../../data/services/board_realtime_service.dart';

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  bool _isDetailMode = false;
  bool _isAddingList = false;

  // PageController for zoom/swipe mode
  PageController? _pageController;

  double get _s => _isDetailMode ? 1.0 : 0.65;

  // Zoom layout: column = 80% screen, gap between columns = 8%, page slot = 88%.
  // Adjacent columns peek at ~(88%-80%)/2 = 4% each side automatically.
  static const double _colFraction = 0.80;
  static const double _vpFraction = _colFraction + 0.08; // 0.88

  List<ListEntity>? _localLists;
  BoardDetailCubit? _cubit;

  bool _isDragging = false;
  final TextEditingController _addListController = TextEditingController();
  String? _joinedBoardId;

  @override
  void dispose() {
    _addListController.dispose();
    _pageController?.dispose();
    if (_joinedBoardId != null) {
      serviceLocator<BoardRealtimeService>().leaveBoard(_joinedBoardId!);
    }
    super.dispose();
  }

  DateTime? _lastAutoSwipe;

  void _onDragStart() {
    if (!_isDragging) {
      setState(() {
        _isDragging = true;
      });
    }
  }

  void _onDragEnd() {
    if (_isDragging) {
      setState(() {
        _isDragging = false;
      });
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_pageController == null) return;

    final now = DateTime.now();
    if (_lastAutoSwipe != null &&
        now.difference(_lastAutoSwipe!) < const Duration(milliseconds: 300)) {
      return;
    }

    final screenW = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    const double edgeThreshold = 60.0;
    final int currentPage = _pageController!.page?.round() ?? 0;
    final int totalPages = _localLists?.length ?? 0;

    if (dx < edgeThreshold && currentPage > 0) {
      _lastAutoSwipe = now;
      _pageController!.animateToPage(
        currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (dx > screenW - edgeThreshold && currentPage < totalPages - 1) {
      _lastAutoSwipe = now;
      _pageController!.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleZoom() {
    setState(() {
      _isDetailMode = !_isDetailMode;
      if (_isDetailMode) {
        _pageController = PageController(viewportFraction: _vpFraction);
      } else {
        _pageController?.dispose();
        _pageController = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    String boardId = '';
    String boardName = 'Board';
    String? backgroundUrl;
    String? workspaceId;
    String? workspaceName;
    String? visibility;

    if (arguments is Map<String, dynamic>) {
      boardId = arguments['boardId'] as String? ?? '';
      boardName = arguments['boardName'] as String? ?? 'Board';
      backgroundUrl = arguments['backgroundUrl'] as String?;
      workspaceId = arguments['workspaceId'] as String?;
      workspaceName = arguments['workspaceName'] as String?;
    } else if (arguments is BoardEntity) {
      boardId = arguments.id;
      boardName = arguments.name;
      backgroundUrl = arguments.backgroundUrl;
      workspaceId = arguments.workspaceId;
      workspaceName = arguments.workspaceName;
      visibility = arguments.visibility;
    }

    return BlocProvider(
      create: (ctx) {
        _cubit = serviceLocator<BoardDetailCubit>()
          ..loadBoard(
            boardId, 
            boardName, 
            backgroundUrl: backgroundUrl,
            workspaceId: workspaceId,
            workspaceName: workspaceName,
            visibility: visibility,
        );
        // Start Join Board Realtime
        _joinedBoardId = boardId;
        serviceLocator<BoardRealtimeService>().joinBoard(boardId);
        return _cubit!;
      },
      child: BlocConsumer<BoardDetailCubit, BoardDetailState>(
        listenWhen: (prev, curr) => curr is BoardDetailLoaded,
        listener: (ctx, state) {
          if (state is BoardDetailLoaded) {
            if (state.transientError != null) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text(state.transientError!)));
              _cubit?.clearTransientError();
            }
            setState(() {
              _localLists = List.from(state.lists);
            });
          }
        },
        builder: (ctx, state) {
          final loadedState = state is BoardDetailLoaded ? state : null;
          final bgUrl = loadedState?.backgroundUrl ?? backgroundUrl;
          final bName = loadedState?.boardName ?? boardName;
          final bColor = AppColors.primaryContainer;

          return Scaffold(
            backgroundColor: bColor,
            body: Container(
              decoration: bgUrl != null && bgUrl.isNotEmpty
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(bgUrl),
                        fit: BoxFit.cover,
                      ),
                    )
                  : BoxDecoration(color: bColor),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    _buildBoardArea(ctx, state),
                    // Customize Header over the board
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bName,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Báo cáo 💯', // Placeholder for workspace/subtitle
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bottom Control Bar
                    Positioned(
                      bottom: 32,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2433),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Comming soon'),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Comming soon'),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => BlocProvider.value(
                                      value: _cubit!,
                                      child: BoardMenuSheet(
                                        boardId: boardId,
                                        boardName: bName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  _isDetailMode
                                      ? Icons.close_fullscreen
                                      : Icons.open_in_full,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleZoom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoardArea(BuildContext context, BoardDetailState state) {
    if (state is BoardDetailLoading || state is BoardDetailInitial) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (state is BoardDetailError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.white)),
      );
    }
    if (state is BoardDetailLoaded) {
      if (_isDetailMode) return _buildZoomSwipeView(state);
      return _buildKanban(state);
    }
    return const SizedBox.shrink();
  }

  // ── Zoom / Swipe view ────────────────────────────────────────────────────
  Widget _buildZoomSwipeView(BoardDetailLoaded state) {
    final lists = _localLists ?? state.lists;
    if (lists.isEmpty) {
      return const Center(
        child: Text('Chưa có cột nào.', style: TextStyle(color: Colors.white)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = MediaQuery.of(context).size.width;
        final colW = screenW * _colFraction;

        return PageView.builder(
          controller: _pageController,
          itemCount: lists.length,
          padEnds: false,
          physics: _isDragging
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final list = lists[index];
            final slotW = screenW * _vpFraction;
            final sidePad = (slotW - colW) / 2;

            return DragTarget<ListDragData>(
              key: ValueKey('zoom_target_${list.id}'),
              onWillAcceptWithDetails: (details) => details.data.id != list.id,
              onAcceptWithDetails: (details) {
                final oldIdx = details.data.initialPosition;
                final newIdx = index;
                final listToMove = details.data.list;

                setState(() {
                  _localLists!.removeAt(oldIdx);
                  _localLists!.insert(newIdx, listToMove);
                });
                _cubit?.moveList(list: listToMove, insertIndex: newIdx);
              },
              builder: (context, candidateLists, _) {
                final isListHovered = candidateLists.isNotEmpty;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isListHovered ? 0.4 : 1.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100, bottom: 120),
                        child: DraggableListWidget(
                          key: ValueKey('zoom_draggable_${list.id}'),
                          list: list,
                          initialPosition: index,
                          boardId: state.boardId,
                          onDragStarted: _onDragStart,
                          onDragEnded: _onDragEnd,
                          onDragUpdate: _handleDragUpdate,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Transform.rotate(
                              angle: 0.02,
                              child: SizedBox(
                                width: colW,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: KanbanColumnZoomWidget(
                                    list: list,
                                    columnWidth: colW,
                                    itemCount: list.cards.length * 2 + 1,
                                    itemBuilder: (i) => i % 2 == 0
                                        ? const SizedBox.shrink()
                                        : KanbanCardUiWidget(
                                            card: list.cards[i ~/ 2],
                                            boardId: state.boardId,
                                            scale: 1.0,
                                            onTap: () {},
                                            onToggleComplete: (val) {
                                              _cubit?.toggleCardStatus(list.id, list.cards[i ~/ 2].id, val);
                                            },
                                          ),
                                    onAddCard: () {},
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: KanbanColumnZoomWidget(
                            list: list,
                            columnWidth: colW,
                            itemCount: list.cards.length * 2 + 1,
                            itemBuilder: (itemIndex) {
                              if (itemIndex % 2 == 0) {
                                return CardSlotWidget(
                                  key: ValueKey(
                                    'zoom_slot_${list.id}_$itemIndex',
                                  ),
                                  targetListId: list.id,
                                  insertIndex: itemIndex ~/ 2,
                                  scale: 1.0,
                                  onAccept: (data, targetIdx) {
                                    _cubit?.moveCard(
                                      card: data.card,
                                      sourceListId: data.sourceListId,
                                      targetListId: list.id,
                                      insertIndex: targetIdx,
                                    );
                                  },
                                );
                              } else {
                                final card = list.cards[itemIndex ~/ 2];
                                return DraggableCardWidget(
                                  key: ValueKey('zoom_card_${card.id}'),
                                  card: card,
                                  sourceListId: list.id,
                                  sourceIndex: itemIndex ~/ 2,
                                  boardId: state.boardId,
                                  scale: 1.0,
                                  onDragStarted: _onDragStart,
                                  onDragEnded: _onDragEnd,
                                  onDragUpdate: _handleDragUpdate,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Transform.rotate(
                                      angle: 0.02,
                                      child: SizedBox(
                                        width: colW - 16,
                                        child: Opacity(
                                          opacity: 0.92,
                                          child: KanbanCardUiWidget(
                                            card: card,
                                            boardId: state.boardId,
                                            scale: 1.0,
                                            elevated: true,
                                            onTap: () {},
                                            onToggleComplete: (val) {
                                              _cubit?.toggleCardStatus(list.id, card.id, val);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: KanbanCardUiWidget(
                                    card: card,
                                    boardId: state.boardId,
                                    scale: 1.0,
                                    onTap: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        '/card-detail',
                                        arguments: {
                                          'card': card,
                                          'boardId': state.boardId,
                                        },
                                      );
                                      _cubit?.loadBoard(
                                        state.boardId,
                                        state.boardName,
                                        backgroundUrl: state.backgroundUrl,
                                        workspaceId: state.workspaceId,
                                        workspaceName: state.workspaceName,
                                        visibility: state.boardVisibility,
                                      );
                                    },
                                    onToggleComplete: (val) {
                                      _cubit?.toggleCardStatus(list.id, card.id, val);
                                    },
                                  ),
                                );
                              }
                            },
                            onAddCard: () => _showAddCardDialog(list.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildKanban(BoardDetailLoaded state) {
    final listsToRender = _localLists ?? state.lists;
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(16 * _s, 100, 16 * _s, 120),
      buildDefaultDragHandles: false,
      autoScrollerVelocityScalar: 2.0,
      proxyDecorator: (child, index, animation) {
        return Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.88,
            child: Transform.rotate(angle: 0.025, child: child),
          ),
        );
      },
      itemCount: listsToRender.length,
      itemBuilder: (context, index) {
        final list = listsToRender[index];
        return Align(
          key: ValueKey(list.id),
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(right: 16 * _s),
            child: RepaintBoundary(
              child: KanbanColumnWidget(
                list: list,
                columnIndex: index,
                scale: _s,
                header: KanbanColumnHeaderWidget(list: list, scale: _s),
                itemBuilder: (itemIndex) {
                  if (itemIndex % 2 == 0) {
                    return CardSlotWidget(
                      targetListId: list.id,
                      insertIndex: itemIndex ~/ 2,
                      scale: _s,
                      onAccept: (data, targetIdx) {
                        _cubit?.moveCard(
                          card: data.card,
                          sourceListId: data.sourceListId,
                          targetListId: list.id,
                          insertIndex: targetIdx,
                        );
                      },
                    );
                  } else {
                    final card = list.cards[itemIndex ~/ 2];
                    return DraggableCardWidget(
                      card: card,
                      sourceListId: list.id,
                      sourceIndex: itemIndex ~/ 2,
                      boardId: state.boardId,
                      scale: _s,
                      onDragStarted: _onDragStart,
                      onDragEnded: _onDragEnd,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Transform.rotate(
                          angle: 0.02,
                          child: SizedBox(
                            width: 264.0 * _s,
                            child: Opacity(
                              opacity: 0.92,
                              child: KanbanCardUiWidget(
                                card: card,
                                boardId: state.boardId,
                                scale: _s,
                                elevated: true,
                                onTap: () {},
                                onToggleComplete: (val) {
                                  _cubit?.toggleCardStatus(list.id, card.id, val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: KanbanCardUiWidget(
                        card: card,
                        boardId: state.boardId,
                        scale: _s,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/card-detail',
                            arguments: {'card': card, 'boardId': state.boardId},
                          );
                          _cubit?.loadBoard(
                            state.boardId,
                            state.boardName,
                            backgroundUrl: state.backgroundUrl,
                          );
                        },
                        onToggleComplete: (val) {
                          _cubit?.toggleCardStatus(list.id, card.id, val);
                        },
                      ),
                    );
                  }
                },
                addCardButton: AddCardButtonWidget(
                  scale: _s,
                  onTap: () => _showAddCardDialog(list.id),
                ),
              ),
            ),
          ),
        );
      },
      footer: Align(
        alignment: Alignment.topCenter,
        child: AddListSectionWidget(
          isAddingList: _isAddingList,
          scale: _s,
          controller: _addListController,
          onAddTap: () => setState(() => _isAddingList = true),
          onCancelTap: () => setState(() {
            _isAddingList = false;
            _addListController.clear();
          }),
          onSubmitted: (name) {
            _cubit?.createList(name);
            setState(() {
              _isAddingList = false;
              _addListController.clear();
            });
          },
        ),
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

  void _showAddCardDialog(String listId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text(
          'Thêm thẻ mới',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tên thẻ',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = ctrl.text.trim();
              if (title.isNotEmpty) {
                _cubit?.createCard(listId: listId, title: title);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}
