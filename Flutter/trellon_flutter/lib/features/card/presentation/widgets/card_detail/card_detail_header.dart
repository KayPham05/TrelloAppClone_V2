import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
class CardDetailTopBar extends StatelessWidget {
  final String title;
  const CardDetailTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.surface.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardDetailTitle extends StatelessWidget {
  final String title;
  final String status;
  final ValueChanged<String>? onStatusToggle;

  const CardDetailTitle({
    super.key,
    required this.title,
    required this.status,
    this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Basic logic to determine if we are in "completed" state visually
    final isCompleted = status.toLowerCase() == 'hoan_thanh' || status.toLowerCase() == 'hoàn thành' || status.toLowerCase() == 'completed';
    final displayText = isCompleted ? 'HOÀN THÀNH' : status.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (onStatusToggle != null) {
                    onStatusToggle!(isCompleted ? 'dang_lam' : 'hoan_thanh');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      if (isCompleted) ...[
                        const Icon(Icons.check_circle, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        displayText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.white : AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Di chuyển',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
