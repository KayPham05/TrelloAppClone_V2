import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final IconData? trailing;
  final Widget? trailingWidget;
  final Color? color;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.trailingWidget,
    this.color,
  });
}

class ProfileMenuGroupWidget extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const ProfileMenuGroupWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(12) : Radius.zero,
                    bottom: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(item.icon, color: item.color ?? AppColors.textPrimary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(color: item.color ?? AppColors.textPrimary, fontSize: 15),
                          ),
                        ),
                        if (item.trailingWidget != null)
                          item.trailingWidget!
                        else if (item.trailing != null)
                          Icon(item.trailing, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Container(height: 0.5, margin: const EdgeInsets.only(left: 48), color: AppColors.border),
              ],
            );
          }),
        ),
      ),
    );
  }
}
