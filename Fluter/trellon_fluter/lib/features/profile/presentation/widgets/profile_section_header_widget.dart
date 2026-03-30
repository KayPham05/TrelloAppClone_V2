import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSectionHeaderWidget extends StatelessWidget {
  final String title;

  const ProfileSectionHeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
