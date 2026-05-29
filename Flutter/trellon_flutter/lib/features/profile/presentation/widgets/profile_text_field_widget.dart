import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apptreolon/core/constants/app_colors.dart';

class ProfileTextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int maxLines;

  const ProfileTextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          maxLines: maxLines,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: readOnly ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? '',
            prefixIcon: icon != null ? Icon(icon, color: AppColors.outline) : null,
            filled: true,
            fillColor: readOnly ? AppColors.surfaceContainerLowest : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
