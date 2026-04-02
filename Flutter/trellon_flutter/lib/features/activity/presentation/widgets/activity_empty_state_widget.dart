import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ActivityEmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const ActivityEmptyStateWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cute dog illustration 
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text('🐺', style: TextStyle(fontSize: 64)),
                  // sparkle icons
                  Positioned(
                    top: 10,
                    right: 18,
                    child: Icon(Icons.auto_awesome, color: AppColors.accent.withOpacity(0.8), size: 16),
                  ),
                  Positioned(
                    top: 16,
                    left: 14,
                    child: Icon(Icons.auto_awesome, color: AppColors.accent.withOpacity(0.5), size: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bạn không có thông báo nào.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onRefresh,
              child: const Text(
                'Kiểm tra lại',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
