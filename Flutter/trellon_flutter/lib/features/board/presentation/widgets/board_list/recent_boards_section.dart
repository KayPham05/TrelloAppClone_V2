import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/board_entity.dart';
import 'board_list_tile.dart';

class RecentBoardsSection extends StatelessWidget {
  final List<BoardEntity> boards;
  const RecentBoardsSection({super.key, required this.boards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                'Bảng Gần Đây',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (boards.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Chưa có bảng nào được truy cập gần đây.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          ...boards.map((b) => BoardListTile(board: b)),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 4),
      ],
    );
  }
}
