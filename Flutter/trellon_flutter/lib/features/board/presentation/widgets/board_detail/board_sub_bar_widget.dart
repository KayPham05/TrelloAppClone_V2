import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoardSubBarWidget extends StatelessWidget {
  final String boardName;
  final Color boardColor;
  final bool isStarred;
  final VoidCallback onToggleStar;

  const BoardSubBarWidget({
    super.key,
    required this.boardName,
    required this.boardColor,
    required this.isStarred,
    required this.onToggleStar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: boardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              boardName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Vertical divider
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          // Favourite button
          GestureDetector(
            onTap: onToggleStar,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isStarred
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Yêu thích',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter
          _boardIconButton(Icons.filter_list_rounded),
          const SizedBox(width: 4),
          // More
          _boardIconButton(Icons.more_horiz_rounded),
        ],
      ),
    );
  }

  Widget _boardIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
