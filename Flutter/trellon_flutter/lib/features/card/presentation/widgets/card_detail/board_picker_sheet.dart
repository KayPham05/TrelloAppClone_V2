import 'package:flutter/material.dart';
import 'package:apptreolon/features/board/data/datasources/board_remote_data_source.dart';
import 'package:apptreolon/features/board/data/models/board_model.dart';
import 'package:apptreolon/features/board/domain/entities/board_entity.dart';
import 'package:apptreolon/core/data_sources/user_local_data_source.dart';

class BoardPickerSheet extends StatefulWidget {
  final BoardRemoteDataSource boardDataSource;
  final String? currentBoardId;

  const BoardPickerSheet({
    super.key,
    required this.boardDataSource,
    this.currentBoardId,
  });

  static Future<BoardEntity?> show(
    BuildContext context, {
    required BoardRemoteDataSource boardDataSource,
    String? currentBoardId,
  }) {
    return showModalBottomSheet<BoardEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BoardPickerSheet(
        boardDataSource: boardDataSource,
        currentBoardId: currentBoardId,
      ),
    );
  }

  @override
  State<BoardPickerSheet> createState() => _BoardPickerSheetState();
}

class _BoardPickerSheetState extends State<BoardPickerSheet> {
  List<BoardModel> _allBoards = [];
  List<BoardModel> _recentBoards = [];
  bool _loading = true;
  String _query = '';
  String? _userUId;

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    try {
      _userUId = await UserLocalDataSource().getUserId();
      if (_userUId == null) return;
      final results = await Future.wait([
        widget.boardDataSource.getAllBoards(_userUId!),
        widget.boardDataSource.getRecentBoards(_userUId!),
      ]);
      setState(() {
        _allBoards = results[0];
        _recentBoards = results[1];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<BoardModel> get _filtered {
    if (_query.isEmpty) return _allBoards;
    final q = _query.toLowerCase();
    return _allBoards.where((b) => b.name.toLowerCase().contains(q)).toList();
  }

  List<BoardModel> get _personal =>
      _filtered.where((b) => b.isPersonal).toList();

  Map<String, List<BoardModel>> get _workspaceGroups {
    final Map<String, List<BoardModel>> groups = {};
    for (final b in _filtered.where((b) => !b.isPersonal)) {
      final ws = b.workspaceName;
      groups.putIfAbsent(ws, () => []).add(b);
    }
    return groups;
  }

  Future<void> _onBoardTap(BoardModel board) async {
    // Check RBAC — viewer cannot move cards to restricted boards
    if (_userUId != null && !board.isPersonal) {
      final role = await widget.boardDataSource.getUserRoleInBoard(
        boardId: board.id,
        userUId: _userUId!,
      );
      // Viewer cannot receive cards
      if (role == 'Viewer') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Bạn không có quyền di chuyển thẻ vào bảng này (chỉ xem).'),
          ));
        }
        return;
      }
    }
    if (mounted) Navigator.of(context).pop(board);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * (7 / 8);

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Chọn bảng',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bảng...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      if (_recentBoards.isNotEmpty && _query.isEmpty) ...[
                        _sectionHeader('Gần đây'),
                        ..._recentBoards
                            .map((b) => _boardTile(b))
                            ,
                      ],
                      if (_personal.isNotEmpty) ...[
                        _sectionHeader('Cá nhân'),
                        ..._personal.map((b) => _boardTile(b)),
                      ],
                      ..._workspaceGroups.entries.expand((entry) => [
                            _sectionHeader(entry.key),
                            ...entry.value.map((b) => _boardTile(b)),
                          ]),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.4,
          ),
        ),
      );

  Widget _boardTile(BoardModel board) {
    final isCurrent = board.id == widget.currentBoardId;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: board.coverColor != null
              ? _parseColor(board.coverColor!)
              : const Color(0xFF0052CC),
          borderRadius: BorderRadius.circular(6),
          image: board.backgroundUrl != null
              ? DecorationImage(
                  image: NetworkImage(board.backgroundUrl!),
                  fit: BoxFit.cover)
              : null,
        ),
        child: board.backgroundUrl != null
            ? null
            : const Icon(Icons.dashboard, color: Colors.white, size: 18),
      ),
      title:
          Text(board.name, style: const TextStyle(fontSize: 15)),
      subtitle: board.workspaceName.isNotEmpty && !board.isPersonal
          ? Text(board.workspaceName,
              style: const TextStyle(fontSize: 12))
          : null,
      trailing: isCurrent
          ? const Icon(Icons.check, color: Color(0xFF0052CC))
          : null,
      onTap: () => _onBoardTap(board),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return const Color(0xFF0052CC);
    }
  }
}
