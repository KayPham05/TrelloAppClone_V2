import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Visibility option item model.
class VisibilityOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  const VisibilityOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const List<VisibilityOption> kVisibilityOptions = [
  VisibilityOption(
    value: 'Private',
    label: 'Riêng tư',
    description:
        'Các thành viên của bảng thông tin và quản trị không gian làm việc có thể xem và sửa bảng thông tin này.',
    icon: Icons.lock_outline_rounded,
  ),
  VisibilityOption(
    value: 'Workspace',
    label: 'Không gian làm việc',
    description:
        'Bất kỳ ai trong không gian làm việc cũng có thể xem bảng thông tin này.',
    icon: Icons.group_outlined,
  ),
  VisibilityOption(
    value: 'Public',
    label: 'Công khai',
    description:
        'Đây là bảng công khai. Bất kỳ ai có liên kết tới bảng này đều có thể thấy được và bảng cũng sẽ hiển thị trên công cụ tìm kiếm như Google. Chỉ có người được mời vào trong bảng mới có thể chỉnh sửa bảng được.',
    icon: Icons.public_rounded,
  ),
];

/// Sub-screen within the Create Board bottom sheet for picking visibility.
class VisibilityPickerSheet extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const VisibilityPickerSheet({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hiển thị',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        ...kVisibilityOptions.map((opt) {
          final isSelected = opt.value == selectedValue;
          return InkWell(
            onTap: () => onSelected(opt.value),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(opt.icon, size: 22, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isSelected)
                    const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                  else
                    const SizedBox(width: 20),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}
