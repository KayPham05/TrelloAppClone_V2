import 'package:flutter/material.dart';
import 'package:apptreolon/features/board/data/datasources/board_remote_data_source.dart';
import 'package:apptreolon/features/board/data/models/list_model.dart';

class ListPickerSheet extends StatefulWidget {
  final String boardId;
  final BoardRemoteDataSource boardDataSource;
  final String? currentListId;

  const ListPickerSheet({
    super.key,
    required this.boardId,
    required this.boardDataSource,
    this.currentListId,
  });

  static Future<ListModel?> show(
    BuildContext context, {
    required String boardId,
    required BoardRemoteDataSource boardDataSource,
    String? currentListId,
  }) {
    return showModalBottomSheet<ListModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListPickerSheet(
        boardId: boardId,
        boardDataSource: boardDataSource,
        currentListId: currentListId,
      ),
    );
  }

  @override
  State<ListPickerSheet> createState() => _ListPickerSheetState();
}

class _ListPickerSheetState extends State<ListPickerSheet> {
  List<ListModel>? _lists;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      final lists = await widget.boardDataSource.getLists(widget.boardId);
      setState(() {
        _lists = lists;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
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
                  'Chọn danh sách',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List items
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _lists == null || _lists!.isEmpty
                    ? const Center(child: Text('Không có danh sách nào'))
                    : ListView.separated(
                        itemCount: _lists!.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final list = _lists![i];
                          final isCurrent = list.id == widget.currentListId;
                          return ListTile(
                            title: Text(list.name, style: const TextStyle(fontSize: 15)),
                            trailing: isCurrent
                                ? const Icon(Icons.check, color: Color(0xFF0052CC))
                                : null,
                            onTap: () => Navigator.of(context).pop(list),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
