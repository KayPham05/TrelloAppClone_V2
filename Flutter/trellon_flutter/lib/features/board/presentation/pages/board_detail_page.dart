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
import '../widgets/zoom_controls_widget.dart';
import '../widgets/board_detail/board_detail_top_bar_widget.dart';
import '../widgets/board_detail/board_detail_sub_bar_widget.dart';
import '../widgets/board_detail/board_kanban_add_list.dart';
import '../widgets/board_detail/board_kanban_card_ui_widget.dart';
import '../widgets/board_detail/board_kanban_card_wrapper.dart';
import '../widgets/board_detail/board_kanban_column_widget.dart';

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  bool _isStarred = false;
  bool _isDetailMode = false;
  bool _isAddingList = false;

  double get _s => _isDetailMode ? 1.0 : 0.65;

  List<ListEntity>? _localLists;
  BoardDetailCubit? _cubit;

  final ValueNotifier<bool> _isDragging = ValueNotifier(false);
  final TextEditingController _addListController = TextEditingController();

  @override
  void dispose() {
    _isDragging.dispose();
    _addListController.dispose();
    super.dispose();
  }

  void _onDragStart() => _isDragging.value = true;
  void _onDragEnd() => _isDragging.value = false;
  void _toggleZoom() => setState(() => _isDetailMode = !_isDetailMode);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    String boardId = '';
    String boardName = 'Board';
    String? backgroundUrl;

    if (arguments is Map<String, dynamic>) {
      boardId = arguments['boardId'] as String? ?? '';
      boardName = arguments['boardName'] as String? ?? 'Board';
      backgroundUrl = arguments['backgroundUrl'] as String?;
    } else if (arguments is BoardEntity) {
      boardId = arguments.id;
      boardName = arguments.name;
      backgroundUrl = arguments.backgroundUrl;
    }

    return BlocProvider(
      create: (ctx) {
        _cubit = serviceLocator<BoardDetailCubit>()
          ..loadBoard(boardId, boardName, backgroundUrl: backgroundUrl);
        return _cubit!;
      },
      child: BlocConsumer<BoardDetailCubit, BoardDetailState>(
        listenWhen: (prev, curr) => curr is BoardDetailLoaded,
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
                child: Column(
                  children: [
                    BoardDetailTopBarWidget(
                      boardName: bName,
                      onBack: () => Navigator.pop(context),
                    ),
                    BoardDetailSubBarWidget(
                      boardName: bName,
                      isStarred: _isStarred,
                      onToggleStar: () => setState(() => _isStarred = !_isStarred),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          _buildBoardArea(ctx, state),
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
        },
      ),
    );
  }

  Widget _buildBoardArea(BuildContext context, BoardDetailState state) {
    if (state is BoardDetailLoading || state is BoardDetailInitial) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (state is BoardDetailError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.white)),
      );
    }
    if (state is BoardDetailLoaded) {
      return _buildKanban(state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildKanban(BoardDetailLoaded state) {
    final listsToRender = _localLists ?? state.lists;
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(16 * _s, 16 * _s, 16 * _s, 120),
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
                          _cubit?.loadBoard(state.boardId, state.boardName,
                              backgroundUrl: state.backgroundUrl);
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
        title: Text('Thêm thẻ mới', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
