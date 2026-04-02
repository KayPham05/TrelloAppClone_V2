import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../domain/entities/board_entity.dart';
import '../../domain/entities/workspace_entity.dart';
import '../pages/board_detail_page.dart';

class WorkspaceSectionWidget extends StatelessWidget {
  final WorkspaceEntity workspace;
  final bool isExpanded;
  final VoidCallback onToggle;

  const WorkspaceSectionWidget({
    super.key,
    required this.workspace,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Workspace header row
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.people_outline, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    workspace.name,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
                Text(
                  'Bảng',
                  style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 13),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? Icons.chevron_right : Icons.expand_more,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        // Boards
        if (isExpanded)
          ...workspace.boards.map((board) => BoardRowWidget(board: board)),
      ],
    );
  }
}

class BoardRowWidget extends StatelessWidget {
  final BoardEntity board;

  const BoardRowWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoardDetailPage(board: board),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                board.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
