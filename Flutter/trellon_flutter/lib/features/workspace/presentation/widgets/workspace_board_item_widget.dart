import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../board/domain/entities/board_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/workspace_cubit.dart';
import '../../../../init_dependencies.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../board/presentation/cubit/board_cubit.dart';

class WorkspaceBoardItemWidget extends StatelessWidget {
  final BoardEntity board;
  final VoidCallback onToggleStar;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleVisibility;
  final bool isStarred;

  const WorkspaceBoardItemWidget({
    super.key,
    required this.board,
    required this.onToggleStar,
    this.onRename,
    this.onDelete,
    this.onToggleVisibility,
    this.isStarred = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, '/board-detail', arguments: {
            'boardId': board.id,
            'boardName': board.name,
            'backgroundUrl': board.backgroundUrl,
            'workspaceId': board.workspaceId,
            'workspaceName': board.workspaceName,
          });
          if (context.mounted) {
            context.read<WorkspaceCubit>().loadWorkspaces();
            final uid = await serviceLocator<UserLocalDataSource>().getUserId();
            if (uid != null && context.mounted) {
              context.read<BoardCubit>().fetchBoardData(uid, '');
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              // Color thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: board.backgroundUrl != null
                  ? Image.network(
                      board.backgroundUrl!,
                      width: 60,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallbackColor(color),
                    )
                  : _buildFallbackColor(color),
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

  Widget _buildFallbackColor(Color color) {
    return Container(
      width: 60,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.45),
          ],
        ),
      ),
    );
  }
}
