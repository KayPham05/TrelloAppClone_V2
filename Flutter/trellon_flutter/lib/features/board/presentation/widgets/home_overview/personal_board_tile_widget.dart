import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/board_entity.dart';


class PersonalBoardTileWidget extends StatelessWidget {
  final BoardEntity board;
  final VoidCallback onTap;

  const PersonalBoardTileWidget({
    super.key,
    required this.board,
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
              color: AppColors.onSurface.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _BoardIcon(board: board),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (board.workspaceName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _visibilityLabel(board.visibility),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }

  String _visibilityLabel(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'public': return 'Công khai';
      case 'workspace': return 'Không gian làm việc';
      default: return 'Riêng tư';
    }
  }
}

class _BoardIcon extends StatelessWidget {
  final BoardEntity board;
  const _BoardIcon({required this.board});

  @override
  Widget build(BuildContext context) {
    if (board.backgroundUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          board.backgroundUrl!,
          width: 66,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildColorBox(),
        ),
      );
    }
    return _buildColorBox();
  }

  Widget _buildColorBox() {
    final color = board.coverColor != null
        ? Color(int.tryParse('0xFF${board.coverColor!.replaceAll('#', '')}') ?? 0xFF0052CC)
        : AppColors.primaryContainer;
    return Container(
      width: 66,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
    );
  }
}
