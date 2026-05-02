import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../card/domain/entities/card_entity.dart';
import '../../../domain/entities/list_entity.dart';
import '../../models/drag_data_models.dart';

class CardSlotWidget extends StatelessWidget {
  final String targetListId;
  final int insertIndex;
  final double scale;
  final Function(CardDragData, int) onAccept;

  const CardSlotWidget({
    super.key,
    required this.targetListId,
    required this.insertIndex,
    required this.scale,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<CardDragData>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data.sourceListId == targetListId) {
          if (data.initialPosition == insertIndex ||
              data.initialPosition == insertIndex - 1) {
            return false;
          }
        }
        return true;
      },
      onAcceptWithDetails: (details) {
        onAccept(details.data, insertIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: isHovered ? 52.0 * scale : 8.0 * scale,
          margin: EdgeInsets.symmetric(horizontal: 8 * scale),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8 * scale),
            border: isHovered
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    width: 1.5 * scale,
                  )
                : null,
          ),
        );
      },
    );
  }
}

class DraggableCardWidget extends StatelessWidget {
  final CardEntity card;
  final String sourceListId;
  final int sourceIndex;
  final String boardId;
  final double scale;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final Function(DragUpdateDetails)? onDragUpdate;
  final Widget child;
  final Widget feedback;

  const DraggableCardWidget({
    super.key,
    required this.card,
    required this.sourceListId,
    required this.sourceIndex,
    required this.boardId,
    required this.scale,
    required this.onDragStarted,
    required this.onDragEnded,
    this.onDragUpdate,
    required this.child,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<CardDragData>(
      data: CardDragData(
        id: card.id,
        boardId: boardId,
        initialPosition: sourceIndex,
        sourceListId: sourceListId,
        card: card,
      ),
      delay: const Duration(milliseconds: 150),
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDragCompleted: onDragEnded,
      onDragEnd: (details) => onDragEnded(),
      onDraggableCanceled: (velocity, offset) => onDragEnded(),
      feedback: feedback,
      childWhenDragging: Container(
        height: 52 * scale,
        margin: EdgeInsets.fromLTRB(8 * scale, 0, 8 * scale, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5 * scale,
          ),
        ),
      ),
      child: child,
    );
  }
}

class DraggableListWidget extends StatelessWidget {
  final ListEntity list;
  final int initialPosition;
  final String boardId;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final Function(DragUpdateDetails)? onDragUpdate;
  final Widget child;
  final Widget feedback;

  const DraggableListWidget({
    super.key,
    required this.list,
    required this.initialPosition,
    required this.boardId,
    required this.onDragStarted,
    required this.onDragEnded,
    this.onDragUpdate,
    required this.child,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<ListDragData>(
      data: ListDragData(
        id: list.id,
        boardId: boardId,
        initialPosition: initialPosition,
        list: list,
      ),
      delay: const Duration(milliseconds: 80),
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDragCompleted: onDragEnded,
      onDragEnd: (details) => onDragEnded(),
      onDraggableCanceled: (velocity, offset) => onDragEnded(),
      feedback: feedback,
      child: child,
    );
  }
}
