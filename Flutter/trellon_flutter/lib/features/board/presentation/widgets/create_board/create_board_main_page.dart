import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../workspace/domain/entities/workspace_entity.dart';

class CreateBoardMainPage extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController nameController;
  final WorkspaceEntity? selectedWorkspace;
  final String selectedVisibility;
  final Color selectedColor;
  final List<Color> presetColors;
  final bool isCreating;
  final ValueChanged<Color> onSelectColor;
  final VoidCallback onTapWorkspace;
  final VoidCallback onTapVisibility;
  final VoidCallback onSubmit;

  const CreateBoardMainPage({
    super.key,
    required this.scrollController,
    required this.nameController,
    required this.selectedWorkspace,
    required this.selectedVisibility,
    required this.selectedColor,
    required this.presetColors,
    required this.isCreating,
    required this.onSelectColor,
    required this.onTapWorkspace,
    required this.onTapVisibility,
    required this.onSubmit,
  });

  String get _visibilityLabel {
    switch (selectedVisibility) {
      case 'Workspace':
        return 'Không gian làm việc';
      case 'Public':
        return 'Công khai';
      default:
        return 'Riêng tư';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerLow,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Bảng',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: isCreating ? null : onSubmit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCreating ? AppColors.outlineVariant : const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isCreating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Tạo mới',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: nameController,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Bảng Mới',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _CreateBoardSettingRow(
                    label: 'Không gian làm việc',
                    valueWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            selectedWorkspace?.name ?? 'Bảng cá nhân',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                      ],
                    ),
                    onTap: onTapWorkspace,
                  ),
                  const Divider(height: 1, indent: 16),
                  _CreateBoardSettingRow(
                    label: 'Hiển thị',
                    valueWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _visibilityLabel,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                      ],
                    ),
                    onTap: onTapVisibility,
                  ),
                  const Divider(height: 1, indent: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Text(
                          'Phông nền',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        ...presetColors.map((c) => GestureDetector(
                              onTap: () => onSelectColor(c),
                              child: Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(4),
                                  border: selectedColor == c
                                      ? Border.all(
                                          color: AppColors.onSurface,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CreateBoardSettingRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final VoidCallback onTap;

  const _CreateBoardSettingRow({
    required this.label,
    required this.valueWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            valueWidget,
          ],
        ),
      ),
    );
  }
}
