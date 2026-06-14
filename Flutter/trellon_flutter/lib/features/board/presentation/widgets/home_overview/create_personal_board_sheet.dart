import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../workspace/domain/entities/workspace_entity.dart';

import '../../cubit/board_cubit.dart';

class CreatePersonalBoardSheet extends StatefulWidget {
  const CreatePersonalBoardSheet({super.key});

  @override
  State<CreatePersonalBoardSheet> createState() =>
      _CreatePersonalBoardSheetState();
}

class _CreatePersonalBoardSheetState extends State<CreatePersonalBoardSheet> {
  final TextEditingController _nameController = TextEditingController();
  String _visibility = 'Private';
  String? _selectedWorkspaceId; // null means Personal
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);
    try {
      if (_selectedWorkspaceId == null) {
        await context.read<BoardCubit>().createPersonalBoard(
          name: name,
          visibility: _visibility,
        );
      } else {
        final state = context.read<BoardCubit>().state;
        bool isPersonal = false;
        if (state is BoardLoaded) {
          final ws = state.allWorkspaces.firstWhere(
            (w) => w.id == _selectedWorkspaceId,
          );
          isPersonal = ws.type == WorkspaceType.personal;
        }

        await context.read<BoardCubit>().createBoard(
          name: name,
          workspaceId: _selectedWorkspaceId!,
          isPersonal: isPersonal,
          visibility: _visibility,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tạo bảng cá nhân',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Tên bảng',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'VD: Kế hoạch du lịch',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mức độ hiển thị',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildVisibilityOption(
              value: 'Private',
              icon: Icons.lock_rounded,
              label: 'Riêng tư',
            ),
            const SizedBox(height: 8),
            _buildVisibilityOption(
              value: 'Public',
              icon: Icons.public_rounded,
              label: 'Công khai',
            ),
            const SizedBox(height: 24),
            Text(
              'Không gian làm việc',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<BoardCubit, BoardState>(
              builder: (context, state) {
                List<WorkspaceEntity> workspaces = [];
                if (state is BoardLoaded) {
                  workspaces = state.allWorkspaces;
                }

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(canvasColor: AppColors.surfaceContainerLow),
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedWorkspaceId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Cá nhân (Không thuộc workspace)'),
                      ),
                      ...workspaces.map(
                        (ws) => DropdownMenuItem<String?>(
                          value: ws.id,
                          child: Text(ws.name),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedWorkspaceId = val),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isCreating ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Tạo bảng',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _visibility == value;
    return InkWell(
      onTap: () => setState(() => _visibility = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
