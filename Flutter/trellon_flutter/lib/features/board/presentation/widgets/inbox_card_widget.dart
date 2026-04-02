import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InboxCardWidget extends StatelessWidget {
  const InboxCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {},
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.inbox_outlined, color: AppColors.textPrimary, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'Hộp thư đến',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
            Container(height: 0.5, color: AppColors.border),
            InkWell(
              onTap: () {},
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Text('Thêm thẻ', style: TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    const Icon(Icons.attachment, color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
