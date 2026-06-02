import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/card_detail_cubit.dart';
import '../../cubit/card_detail_state.dart';

/// Bottom sheet opened by the ⊕ button in the card detail header.
class CardAddActionsSheet extends StatelessWidget {
  final String boardId;
  final bool allowJoinCard;
  final VoidCallback? onMembersTap;
  final VoidCallback? onChecklistTap;
  final VoidCallback? onAttachmentTap;

  const CardAddActionsSheet({
    super.key,
    required this.boardId,
    required this.allowJoinCard,
    this.onMembersTap,
    this.onChecklistTap,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardDetailCubit, CardDetailState>(
      listener: (context, state) {
        if (state is CardDetailLoaded) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tham gia thẻ thành công!')),
          );
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Text('Thêm vào thẻ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (allowJoinCard)
                _ActionTile(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Tham gia thẻ',
                  onTap: () {
                    context.read<CardDetailCubit>().joinCard(boardId);
                    Navigator.pop(context);
                  },
                ),
              _ActionTile(
                icon: Icons.group_outlined,
                label: 'Thành viên',
                onTap: () {
                  Navigator.pop(context);
                  onMembersTap?.call();
                },
              ),
              _ActionTile(
                icon: Icons.check_box_outlined,
                label: 'Thêm Danh sách công việc',
                onTap: () {
                  Navigator.pop(context);
                  onChecklistTap?.call();
                },
              ),
              _ActionTile(
                icon: Icons.attach_file_rounded,
                label: 'Tệp đính kèm',
                onTap: () {
                  Navigator.pop(context);
                  onAttachmentTap?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
    );
  }
}
