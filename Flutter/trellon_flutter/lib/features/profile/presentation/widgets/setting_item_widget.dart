import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SettingItem extends StatelessWidget{
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconBgColor;
  final Color iconColor;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const SettingItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  }): super(key: key);

  @override
  Widget build(BuildContext context){
    return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  (showChevron
                      ? const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.outlineVariant,
                          size: 24,
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      );
  }
}