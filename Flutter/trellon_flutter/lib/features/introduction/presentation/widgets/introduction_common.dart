import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class IntroductionAppBar extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onSkip;
  final VoidCallback? onBack;
  final bool isActionText;

  const IntroductionAppBar({
    super.key,
    required this.title,
    required this.actionText,
    this.onSkip,
    this.onBack,
    this.isActionText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: onBack,
          )
        else
          const SizedBox(width: 48),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: onSkip,
            child: Text(
              actionText,
              style: GoogleFonts.inter(
                color: isActionText ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isActionText ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

class IntroductionPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const IntroductionPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: onPressed == null ? AppColors.surfaceContainerHigh : AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        gradient: onPressed != null
            ? const LinearGradient(
                colors: [AppColors.primary, Color(0xFF0F3B99)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: onPressed == null ? AppColors.onSurfaceVariant : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward,
                  color: onPressed == null ? AppColors.onSurfaceVariant : Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
