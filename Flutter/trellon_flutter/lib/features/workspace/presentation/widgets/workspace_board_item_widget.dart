import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../board/domain/entities/board_entity.dart';

class WorkspaceBoardItemWidget extends StatelessWidget {
  final BoardEntity board;
  final VoidCallback onToggleStar;

  const WorkspaceBoardItemWidget({
    super.key,
    required this.board,
    required this.onToggleStar,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');
    // Using a simple logic for mockup favorites until star is added to backend model
    final bool isStarred = false; 

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
              Expanded(
                child: Text(
                  board.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleStar,
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
                icon: Icon(
                  isStarred
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 18,
                  color: isStarred
                      ? const Color(0xFFF59E0B)
                      : AppColors.outlineVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
