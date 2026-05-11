import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apptreolon/features/board/data/datasources/board_remote_data_source.dart';
import 'package:apptreolon/features/board/data/models/list_model.dart';
import 'package:apptreolon/features/board/domain/entities/board_entity.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/card/presentation/cubit/card_detail_cubit.dart';
import 'package:apptreolon/features/inbox/presentation/bloc/inbox_cubit.dart';
import 'package:apptreolon/features/inbox/presentation/bloc/inbox_state.dart';
import 'board_picker_sheet.dart';
import 'list_picker_sheet.dart';
import 'position_picker_sheet.dart';

class MoveCardSheet extends StatefulWidget {
  final CardEntity card;
  final String? currentBoardId;
  final BoardRemoteDataSource boardDataSource;
  final CardDetailCubit cubit;

  const MoveCardSheet({
    super.key,
    required this.card,
    this.currentBoardId,
    required this.boardDataSource,
    required this.cubit,
  });

  static Future<void> show(
    BuildContext context, {
    required CardEntity card,
    String? currentBoardId,
    required BoardRemoteDataSource boardDataSource,
    required CardDetailCubit cubit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoveCardSheet(
        card: card,
        currentBoardId: currentBoardId,
        boardDataSource: boardDataSource,
        cubit: cubit,
      ),
    );
  }

  @override
  State<MoveCardSheet> createState() => _MoveCardSheetState();
}

class _MoveCardSheetState extends State<MoveCardSheet> {
  // 0 = Inbox, 1 = Board
  int _selectedTab = 0;
  bool _isLoading = false;

  // Inbox
  int _inboxPosition = 1; // 1-indexed for display

  // Board
  BoardEntity? _selectedBoard;
  ListModel? _selectedList;
  int _boardPosition = 1; // 1-indexed for display
  int _listCardCount = 0;

  int get _inboxCardCount {
    final s = context.read<InboxCubit>().state;
    if (s is InboxLoaded) return s.cards.length;
    return 0;
  }

  bool get _canMove {
    if (_selectedTab == 0) return true;
    return _selectedBoard != null && _selectedList != null;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * (7 / 8);

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F2F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Di chuyển thẻ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : ElevatedButton(
                        onPressed: _canMove ? _doMove : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Di chuyển', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tab selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabChip('Hộp thư đến', 0),
                const SizedBox(width: 8),
                _buildTabChip('Bảng', 1),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedTab == 0 ? _buildInboxTab() : _buildBoardTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F0FE) : Colors.grey.shade200,
          border: Border.all(
            color: selected ? const Color(0xFF0052CC) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF0052CC) : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInboxTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Vị trí', style: TextStyle(fontSize: 15)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_inboxPosition',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () async {
          final total = _inboxCardCount + 1; // +1 for the card being moved
          final result = await PositionPickerSheet.show(
            context,
            currentPosition: _inboxPosition,
            totalPositions: total,
          );
          if (result != null) setState(() => _inboxPosition = result);
        },
      ),
    );
  }

  Widget _buildBoardTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Bảng', style: TextStyle(fontSize: 15)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedBoard != null)
                  Text(
                    _selectedBoard!.name,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () async {
              final result = await BoardPickerSheet.show(
                context,
                boardDataSource: widget.boardDataSource,
              );
              if (result != null) {
                setState(() {
                  _selectedBoard = result;
                  _selectedList = null;
                  _boardPosition = 1;
                  _listCardCount = 0;
                });
              }
            },
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            enabled: _selectedBoard != null,
            title: Text(
              'Danh sách',
              style: TextStyle(
                fontSize: 15,
                color: _selectedBoard != null ? Colors.black : Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedList != null)
                  Text(
                    _selectedList!.name,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: _selectedBoard == null
                ? null
                : () async {
                    final result = await ListPickerSheet.show(
                      context,
                      boardId: _selectedBoard!.id,
                      boardDataSource: widget.boardDataSource,
                      currentListId: _selectedList?.id,
                    );
                    if (result != null) {
                      setState(() {
                        _selectedList = result;
                        _listCardCount = 0; // position set to end by default
                        _boardPosition = 1;
                      });
                    }
                  },
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            enabled: _selectedList != null,
            title: Text(
              'Vị trí',
              style: TextStyle(
                fontSize: 15,
                color: _selectedList != null ? Colors.black : Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_boardPosition',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: _selectedList == null
                ? null
                : () async {
                    final total = _listCardCount + 1;
                    final result = await PositionPickerSheet.show(
                      context,
                      currentPosition: _boardPosition,
                      totalPositions: total,
                    );
                    if (result != null) setState(() => _boardPosition = result);
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _doMove() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedTab == 0) {
        // Move to Inbox
        await widget.cubit.moveToInbox(_inboxPosition - 1); // 0-indexed
      } else {
        // Move to Board
        await widget.cubit.moveToBoard(_selectedList!.id, _boardPosition - 1);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi di chuyển thẻ')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
