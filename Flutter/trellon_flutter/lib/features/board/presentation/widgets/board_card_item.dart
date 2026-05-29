import 'package:flutter/material.dart';
import '../../domain/entities/board_entity.dart';
import '../../../../core/utils/color_utils.dart';

class BoardCardItem extends StatelessWidget {
  final BoardEntity board;
  final VoidCallback? onTap;

  const BoardCardItem({super.key, required this.board, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              board.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Spacer(),
                Icon(
                  board.visibility == 'Private' ? Icons.lock_outline : Icons.public,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
