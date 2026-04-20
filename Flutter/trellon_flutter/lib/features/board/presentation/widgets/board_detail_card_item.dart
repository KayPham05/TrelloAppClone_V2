import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../../../card/presentation/pages/card_detail_page.dart';
import '../cubit/board_detail_cubit.dart';
import '../cubit/board_detail_state.dart';

/// Draggable card item for the board kanban view
class BoardDetailCardItem extends StatelessWidget {
  final CardEntity card;

  const BoardDetailCardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Draggable<CardEntity>(
      data: card,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            card.title,
            style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _buildCardContent(context),
      ),
      child: _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final cubit = context.read<BoardDetailCubit>();
        final state = cubit.state;
        
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
        );
        
        if (state is BoardDetailLoaded) {
          cubit.loadBoard(
            boardId: state.boardId,
            boardName: state.boardName,
            backgroundUrl: state.backgroundUrl,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.backgroundUrl != null && card.backgroundUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  card.backgroundUrl!,
                  height: 100, // Roughly 50% increase max for small cards
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (card.description != null && card.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      card.description!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (card.dueDate != null || card.todoItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _buildMeta(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        if (card.dueDate != null) ...[
          const Icon(Icons.schedule, color: AppColors.warning, size: 12),
          const SizedBox(width: 3),
          Text(
            '${card.dueDate!.day}/${card.dueDate!.month}',
            style: const TextStyle(color: AppColors.warning, fontSize: 11),
          ),
          const SizedBox(width: 8),
        ],
        if (card.todoItems.isNotEmpty) ...[
          const Icon(Icons.check_box_outlined, color: AppColors.textSecondary, size: 12),
          const SizedBox(width: 3),
          Text(
            '${card.todoItems.where((t) => t.isCompleted).length}/${card.todoItems.length}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ],
    );
  }
}
