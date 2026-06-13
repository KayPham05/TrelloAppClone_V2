import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/board_detail_cubit.dart';

/// Widget for inline card creation form inside a list
class AddCardFormWidget extends StatefulWidget {
  final String listId;
  final VoidCallback onCancel;

  const AddCardFormWidget({
    super.key,
    required this.listId,
    required this.onCancel,
  });

  @override
  State<AddCardFormWidget> createState() => _AddCardFormWidgetState();
}

class _AddCardFormWidgetState extends State<AddCardFormWidget> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    setState(() => _loading = true);
    await context.read<BoardDetailCubit>().createCard(
      listId: widget.listId,
      title: title,
    );
    if (mounted) widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 1,
            autofocus: true,
            style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Nhập tiêu đề thẻ...',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                if (_loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Thêm thẻ',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
