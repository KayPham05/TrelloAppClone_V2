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
              title: 'Step 4 of 5',
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
                    'Your Privacy\nMatters',
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
                    'Review our Terms of Service and Privacy Policy to understand how we protect your data.',
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
                      'I agree to the Terms of Service', _agreedTerms, (v) => setState(() => _agreedTerms = v!)),
                  const SizedBox(height: 12),
                  _buildCheckboxRow(
                      'I agree to the Privacy Policy', _agreedPrivacy, (v) => setState(() => _agreedPrivacy = v!)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: IntroductionPrimaryButton(
              text: 'Continue',
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
