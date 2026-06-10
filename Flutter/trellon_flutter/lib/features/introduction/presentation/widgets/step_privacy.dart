import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'introduction_common.dart';

class StepPrivacy extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepPrivacy({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepPrivacy> createState() => _StepPrivacyState();
}

class _StepPrivacyState extends State<StepPrivacy> {
  bool _agreedTerms = false;
  bool _agreedPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: IntroductionAppBar(
              title: 'Bước 4 / 5',
              actionText: '',
              onBack: widget.onBack,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Quyền riêng tư\ncủa bạn',
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
                    'Xem lại Điều khoản dịch vụ và Chính sách quyền riêng tư để hiểu cách chúng tôi bảo vệ dữ liệu của bạn.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4D68), Color(0xFFC0D2D9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.security, size: 80, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildCheckboxRow(
                      'Tôi đồng ý với Điều khoản dịch vụ', _agreedTerms, (v) => setState(() => _agreedTerms = v!)),
                  const SizedBox(height: 12),
                  _buildCheckboxRow(
                      'Tôi đồng ý với Chính sách quyền riêng tư', _agreedPrivacy, (v) => setState(() => _agreedPrivacy = v!)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: IntroductionPrimaryButton(
              text: 'Tiếp tục',
              onPressed: (_agreedTerms && _agreedPrivacy) ? widget.onNext : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: const CircleBorder(),
            side: const BorderSide(color: AppColors.outlineVariant),
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
