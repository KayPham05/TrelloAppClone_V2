import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Popup menu shown when the blue [+] button is tapped.
/// Call [showHomeActionMenu] with the context, onCreateBoard, and onCreateWorkspace callbacks.
Future<void> showHomeActionMenu(
  BuildContext context, {
  required VoidCallback onCreateBoard,
  required VoidCallback onCreateWorkspace,
}) async {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  await showMenu(
    context: context,
    position: position,
    color: AppColors.surfaceContainerLowest,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 8,
    items: [
      _buildMenuItem(
        value: 'board',
        icon: Icons.grid_view_rounded,
        label: 'Tạo Bảng',
        subtitle: 'Một bảng được tạo thành từ các thẻ',
      ),
      _buildMenuItem(
        value: 'workspace',
        icon: Icons.group_add_rounded,
        label: 'Tạo Không gian làm việc',
        subtitle: 'Một không gian làm việc là nơi nhóm của bạn cộng tác',
      ),
      _buildMenuItem(
        value: 'card',
        icon: Icons.crop_portrait_rounded,
        label: 'Tạo một thẻ',
        subtitle: 'Một thẻ thường dùng để đại diện cho một mục hoặc dự án',
      ),
      _buildMenuItem(
        value: 'templates',
        icon: Icons.layers_outlined,
        label: 'Duyệt các mẫu',
        subtitle: null,
      ),
    ],
  ).then((value) {
    if (value == 'board') {
      onCreateBoard();
    } else if (value == 'workspace') {
      onCreateWorkspace();
    }
  });
}

PopupMenuItem<String> _buildMenuItem({
  required String value,
  required IconData icon,
  required String label,
  String? subtitle,
}) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.onSurface),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
