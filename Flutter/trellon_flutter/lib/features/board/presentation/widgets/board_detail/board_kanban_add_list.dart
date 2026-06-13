import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class AddListSectionWidget extends StatelessWidget {
  final bool isAddingList;
  final double scale;
  final TextEditingController controller;
  final VoidCallback onAddTap;
  final VoidCallback onCancelTap;
  final Function(String) onSubmitted;

  const AddListSectionWidget({
    super.key,
    required this.isAddingList,
    required this.scale,
    required this.controller,
    required this.onAddTap,
    required this.onCancelTap,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (isAddingList) {
      return Container(
        width: 200 * scale,
        margin: EdgeInsets.only(left: 8 * scale),
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tên cột',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        onSubmitted(name);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Thêm',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                GestureDetector(
                  onTap: onCancelTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: 200 * scale,
        margin: EdgeInsets.only(left: 8 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1 * scale,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18 * scale),
            SizedBox(width: 6 * scale),
            Text(
              'Thêm cột mới',
              style: GoogleFonts.inter(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
