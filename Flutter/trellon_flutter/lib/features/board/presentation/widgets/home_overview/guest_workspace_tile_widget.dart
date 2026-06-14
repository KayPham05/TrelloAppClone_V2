import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../workspace/domain/entities/workspace_entity.dart';

class GuestWorkspaceTileWidget extends StatelessWidget {
  final WorkspaceEntity workspace;
  final VoidCallback onTap;

  const GuestWorkspaceTileWidget({
    super.key,
    required this.workspace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _WorkspaceAvatar(workspace: workspace),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    workspace.description?.isNotEmpty == true
                        ? workspace.description!
                        : 'Không gian làm việc nhóm',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outlineVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceAvatar extends StatelessWidget {
  final WorkspaceEntity workspace;
  const _WorkspaceAvatar({required this.workspace});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : 'W',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
