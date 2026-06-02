import 'package:flutter/material.dart';
import '../theme/azure_auth_theme.dart';

/// Widget text field dùng chung cho các màn hình xác thực (Giao diện Azure Workspace)
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText; 
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AzureAuthTheme.labelMd,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AzureAuthTheme.bodyLg.copyWith(color: AzureAuthTheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AzureAuthTheme.bodyLg.copyWith(color: AzureAuthTheme.onSurfaceVariant),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AzureAuthTheme.onSurfaceVariant, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4), 
              borderSide: const BorderSide(color: AzureAuthTheme.outlineVariant, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AzureAuthTheme.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AzureAuthTheme.azureBlue, width: 1), 
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AzureAuthTheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AzureAuthTheme.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// Backward compat alias
typedef AuthTextFieldWidget = AuthTextField;
