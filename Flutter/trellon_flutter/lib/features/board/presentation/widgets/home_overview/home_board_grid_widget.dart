import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/color_utils.dart';
import '../../../domain/entities/board_entity.dart';
import 'home_create_board_widget.dart';

class HomeBoardGridWidget extends StatelessWidget {
  final List<BoardEntity> boards;
  final bool isStarredGroup;
  final VoidCallback onCreateBoard;

  const HomeBoardGridWidget({
    super.key,
    required this.boards,
    required this.isStarredGroup,
    required this.onCreateBoard,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: boards.length + (isStarredGroup ? 0 : 1),
      itemBuilder: (context, index) {
        if (!isStarredGroup && index == boards.length) {
          return HomeCreateBoardWidget(onTap: onCreateBoard);
        }
        final board = boards[index];
        return HomeBoardCardWidget(board: board);
      },
    );
  }
}

class HomeBoardCardWidget extends StatelessWidget {
  final BoardEntity board;

  const HomeBoardCardWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/board-detail', arguments: {
        'boardId': board.id,
        'boardName': board.name,
        'backgroundUrl': board.backgroundUrl,
      }),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: color),
                    // Subtle pattern overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        board.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_outline_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
