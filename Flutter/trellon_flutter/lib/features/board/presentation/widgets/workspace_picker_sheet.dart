import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../workspace/domain/entities/workspace_entity.dart';

/// Sub-screen within the Create Board bottom sheet for picking a workspace.
/// Shows all available workspaces loaded from [workspaces] and highlights the selected one.
class WorkspacePickerSheet extends StatelessWidget {
  final List<WorkspaceEntity> workspaces;
  final WorkspaceEntity? selectedWorkspace;
  final ValueChanged<WorkspaceEntity?> onSelected;

  const WorkspacePickerSheet({
    super.key,
    required this.workspaces,
    required this.selectedWorkspace,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Không gian làm việc',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        // HARDCODED PERSONAL OPTION
        InkWell(
          onTap: () => onSelected(null),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bảng cá nhân (Không thuộc workspace)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                if (selectedWorkspace == null)
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        if (workspaces.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Không có không gian làm việc nào.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          ...workspaces.map((ws) {
            final isSelected = selectedWorkspace?.id == ws.id;
            return InkWell(
              onTap: () => onSelected(ws),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ws.type == WorkspaceType.personal
                            ? AppColors.primaryContainer.withValues(alpha: 0.8)
                            : const Color(0xFF7C3AED).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        ws.type == WorkspaceType.personal
                            ? Icons.person_rounded
                            : Icons.group_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ws.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}
