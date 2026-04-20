import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class EmptyBoardHint extends StatelessWidget {
  final VoidCallback onCreateBoard;
  const EmptyBoardHint({super.key, required this.onCreateBoard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        'Xin mời tạo bảng mới',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
