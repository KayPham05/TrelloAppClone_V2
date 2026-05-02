import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../board/domain/entities/board_entity.dart';

class WorkspaceBoardItemWidget extends StatelessWidget {
  final BoardEntity board;
  final VoidCallback onToggleStar;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleVisibility;

  const WorkspaceBoardItemWidget({
    super.key,
    required this.board,
    required this.onToggleStar,
    this.onRename,
    this.onDelete,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');
    const bool isStarred = false;

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/board-detail', arguments: {
          'boardId': board.id,
          'boardName': board.name,
          'backgroundUrl': board.backgroundUrl,
        }),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              // Color thumbnail
              Container(
                width: 40,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.95),
                      color.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Board name + visibility
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          board.visibility == 'Public'
                              ? Icons.public_rounded
                              : Icons.lock_outline_rounded,
                          size: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          board.visibility,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Star toggle
              IconButton(
                onPressed: onToggleStar,
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
                icon: Icon(
                  isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 18,
                  color: isStarred ? const Color(0xFFF59E0B) : AppColors.outlineVariant,
                ),
              ),
              // Board actions menu
              if (onRename != null || onDelete != null || onToggleVisibility != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':        onRename?.call();          break;
                      case 'visibility':    onToggleVisibility?.call(); break;
                      case 'delete':        onDelete?.call();           break;
                    }
                  },
                  itemBuilder: (_) => [
                    if (onRename != null)
                      const PopupMenuItem(
                        value: 'rename',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.drive_file_rename_outline_rounded, size: 18),
                          title: Text('Đổi tên'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (onToggleVisibility != null)
                      const PopupMenuItem(
                        value: 'visibility',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.visibility_outlined, size: 18),
                          title: Text('Thay đổi hiển thị'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red.shade400),
                          title: Text('Xóa board',
                              style: TextStyle(color: Colors.red.shade400)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
