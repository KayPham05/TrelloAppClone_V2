import 'package:flutter/material.dart';
import '../../../../core/utils/color_utils.dart';
import '../../data/board_mock_data.dart';
import '../../domain/entities/board_entity.dart';
import '../widgets/add_list_button_widget.dart';
import '../widgets/list_column_widget.dart';

class BoardDetailPage extends StatelessWidget {
  final BoardEntity? board;

  const BoardDetailPage({super.key, this.board});

  @override
  Widget build(BuildContext context) {
    final boardData = board;
    final coverColor = ColorUtils.hexToColor(boardData?.coverColor ?? '#0079BF');
    final lists = BoardMockData.getListsForBoard(boardData?.id ?? 'board-1');

    return Scaffold(
      backgroundColor: coverColor.withOpacity(0.85),
      appBar: AppBar(
        backgroundColor: coverColor.withOpacity(0.7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          boardData?.name ?? 'Board Detail',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: lists.length + 1,
        itemBuilder: (context, index) {
          if (index == lists.length) {
            return const AddListButtonWidget();
          }
          return ListColumnWidget(list: lists[index]);
        },
      ),
    );
  }
}
