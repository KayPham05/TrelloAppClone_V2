import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apptreolon/features/board/data/datasources/board_remote_data_source.dart';
import 'package:apptreolon/init_dependencies.dart';
import '../../cubit/card_detail_cubit.dart';
import '../../cubit/card_detail_state.dart';
import 'move_card_sheet.dart';

/// Bottom sheet opened by the ⋯ button in the card detail header.
class CardMoreActionsSheet extends StatelessWidget {
  final String boardId;
  final bool canManage;

  const CardMoreActionsSheet({super.key, required this.boardId, required this.canManage});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardDetailCubit>();
    return SafeArea(
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
                  Text('Hành động thẻ',
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
            _ActionTile(
              icon: Icons.open_with_rounded,
              label: 'Di chuyển thẻ',
              onTap: () {
                final state = cubit.state;
                if (state is! CardDetailLoaded) return;
                Navigator.pop(context);
                MoveCardSheet.show(
                  context,
                  card: state.card,
                  currentBoardId: boardId,
                  boardDataSource: serviceLocator<BoardRemoteDataSource>(),
                  cubit: cubit,
                );
              },
            ),
            _ActionTile(
              icon: Icons.copy_rounded,
              label: 'Sao chép thẻ',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            _ActionTile(
              icon: Icons.link_rounded,
              label: 'Sao chép liên kết',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép liên kết')),
                );
              },
            ),
            _ActionTile(
              icon: Icons.share_rounded,
              label: 'Chia sẻ liên kết',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            if (canManage) ...[
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.archive_rounded,
                label: 'Lưu trữ thẻ',
                onTap: () {
                  Navigator.pop(context);
                  cubit.archiveCard();
                },
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Xóa thẻ',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xóa thẻ'),
                      content: const Text(
                          'Bạn có chắc muốn xóa thẻ này? Hành động này không thể hoàn tác.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) cubit.deleteCard();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey[700]!;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
    );
  }
}
