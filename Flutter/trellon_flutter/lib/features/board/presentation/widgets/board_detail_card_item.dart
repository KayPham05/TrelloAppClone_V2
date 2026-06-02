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
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0x21091E42), // rgba(9,30,66,0.13)
                blurRadius: 3,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Text(
            card.title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
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
        final boardId = state is BoardDetailLoaded ? state.boardId : null;
        final boardName = state is BoardDetailLoaded ? state.boardName : null;
        final boardBackgroundUrl = state is BoardDetailLoaded ? state.backgroundUrl : null;
        // Find the list name by card.listId
        final listName = state is BoardDetailLoaded
            ? state.lists
                .where((l) => l.id == card.listId)
                .map((l) => l.name)
                .firstOrNull
            : null;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CardDetailPage(
              card: card,
              boardId: boardId,
              boardName: boardName,
              listName: listName,
              boardBackgroundUrl: boardBackgroundUrl,
            ),
          ),
        );

        if (state is BoardDetailLoaded) {
          cubit.loadBoard(state.boardId, state.boardName, backgroundUrl: state.backgroundUrl);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0x21091E42), // rgba(9,30,66,0.13)
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
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
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabels(),
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
            if (card.dueDate != null || card.todoItems.isNotEmpty || card.comments.isNotEmpty || card.fileUrls.isNotEmpty || (card.description != null && card.description!.isNotEmpty) || card.members.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _buildMeta(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabels() {
    if (card.labels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: card.labels.map((l) {
            Color color;
            if (l.colorCode.isNotEmpty) {
              final buffer = StringBuffer();
              if (l.colorCode.length == 6 || l.colorCode.length == 7) buffer.write('ff');
              buffer.write(l.colorCode.replaceFirst('#', ''));
              color = Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFF9E9E9E);
            } else {
              color = Colors.grey;
            }
            return Container(
              height: 8,
              width: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
        }).toList(),
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (card.dueDate != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, color: AppColors.warning, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${card.dueDate!.day}/${card.dueDate!.month}',
                    style: const TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ],
              ),
            if (card.description != null && card.description!.isNotEmpty)
              const Icon(Icons.subject, color: AppColors.textSecondary, size: 14),
            if (card.comments.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${card.comments.length}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            if (card.fileUrls.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_file, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${card.fileUrls.length}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            if (card.todoItems.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_box_outlined, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${card.todoItems.where((t) => t.isCompleted).length}/${card.todoItems.length}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        if (card.members.isNotEmpty)
          Row(
            children: card.members.take(3).map((m) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    (m.userName ?? 'U').substring(0, 1),
                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
