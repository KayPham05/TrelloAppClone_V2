import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/list_model.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../cubit/board_detail_cubit.dart';
import 'add_card_form_widget.dart';
import 'board_detail_card_item.dart';

/// A single list column in the Kanban board
class BoardDetailListColumn extends StatefulWidget {
  final ListEntityData listData;

  const BoardDetailListColumn({super.key, required this.listData});

  @override
  State<BoardDetailListColumn> createState() => _BoardDetailListColumnState();
}

class _BoardDetailListColumnState extends State<BoardDetailListColumn> {
  bool _isAddingCard = false;
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [_buildListHeader(context), _buildCardArea(context)],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.listData.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
          _buildListMenu(context),
        ],
      ),
    );
  }

  Widget _buildListMenu(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => _ListMenuSheet(
            listId: widget.listData.id,
            listName: widget.listData.name,
          ),
        );
      },
      child: const Icon(
        Icons.more_horiz,
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }

  Widget _buildCardArea(BuildContext context) {
    return DragTarget<CardEntity>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isDragOver = true);
        return details.data.listId != widget.listData.id;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        context.read<BoardDetailCubit>().moveCard(
          card: details.data,
          sourceListId: details.data.listId ?? '',
          targetListId: widget.listData.id,
          insertIndex: widget.listData.cards.length,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isDragOver
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
            border: _isDragOver
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.listData.cards.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.listData.cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      BoardDetailCardItem(card: widget.listData.cards[i]),
                ),
              if (_isAddingCard)
                AddCardFormWidget(
                  listId: widget.listData.id,
                  onCancel: () => setState(() => _isAddingCard = false),
                )
              else
                _buildAddCardButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddCardButton() {
    return InkWell(
      onTap: () => setState(() => _isAddingCard = true),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.add, color: AppColors.textSecondary, size: 18),
            SizedBox(width: 6),
            Text(
              'Thêm thẻ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListMenuSheet extends StatelessWidget {
  final String listId;
  final String listName;

  const _ListMenuSheet({required this.listId, required this.listName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            listName,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text(
              'Xóa danh sách',
              style: TextStyle(color: AppColors.onSurface),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<BoardDetailCubit>().deleteList(listId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close, color: AppColors.textSecondary),
            title: const Text(
              'Đóng',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
