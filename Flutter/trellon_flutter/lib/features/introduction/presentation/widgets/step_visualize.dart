import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'introduction_common.dart';

class StepVisualize extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const StepVisualize({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: IntroductionAppBar(
              title: 'Bước 2 / 5',
              actionText: '',
              onSkip: onSkip,
              onBack: onBack,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Trực quan hóa\ntiến trình',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sử dụng các bảng để theo dõi dự án từ ý tưởng đến hoàn thành. Giao diện trực quan biến các quy trình phức tạp thành các hành trình rõ ràng.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(color: AppColors.primaryContainer, width: 4),
                        ),
                        child: const Center(
                          child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: IntroductionPrimaryButton(text: 'Bước tiếp theo', onPressed: onNext),
          ),
        ],
      ),
    );
  }
}
