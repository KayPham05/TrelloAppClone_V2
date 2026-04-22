import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../workspace/domain/entities/workspace_entity.dart';
import '../../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../../workspace/presentation/pages/workspace_menu_page.dart';
import 'board_list_tile.dart';

class WorkspaceSection extends StatelessWidget {
  final WorkspaceEntity workspace;
  final VoidCallback onAddBoard;

  const WorkspaceSection({
    super.key,
    required this.workspace,
    required this.onAddBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<WorkspaceCubit>(),
                child: WorkspaceMenuPage(workspace: workspace),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  workspace.type == WorkspaceType.personal
                      ? Icons.people_alt_outlined
                      : Icons.group_outlined,
                  size: 22,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    workspace.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Text(
                  'Bảng',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
        if (workspace.boards.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Xin mời tạo bảng mới',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...workspace.boards
              .cast<dynamic>()
              .map((b) => BoardListTileFromDynamic(board: b)),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
