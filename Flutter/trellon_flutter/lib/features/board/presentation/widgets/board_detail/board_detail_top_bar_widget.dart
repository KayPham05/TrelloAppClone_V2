import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';


class BoardDetailTopBarWidget extends StatelessWidget {
  final String boardName;
  final VoidCallback onBack;
  final VoidCallback? onSettingsTap;

  const BoardDetailTopBarWidget({
    super.key,
    required this.boardName,
    required this.onBack,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1D4ED8)),
            onPressed: onBack,
          ),
          const Icon(Icons.grid_view_rounded, color: Color(0xFF1D4ED8), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              boardName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A8A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B)),
            onPressed: onSettingsTap,
          ),
          const AvatarChipWidget(),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class AvatarChipWidget extends StatelessWidget {
  const AvatarChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 4),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'U',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
