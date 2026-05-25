import 'dart:async';

import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:apptreolon/core/utils/validators/validator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../init_dependencies.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  //key
  final _formKey = GlobalKey<FormState>();
  final _confirmPassKey = GlobalKey<FormFieldState>();

  //debounce
  Timer? _debounce;

  //Controller
  late TextEditingController _oldPass;
  late TextEditingController _newPass;
  late TextEditingController _newPassConfirm;
  late TextEditingController _twoFactorCode;

  //helpers
  bool isSubmitting = false;
  bool _isTwoFactorEnabled = false;
  bool _isLoadingUserInfo = true;

  // Toggle mật khẩu hiện/ẩn
  bool _obscureOldPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  late FocusNode _newPassFocus;
  late FocusNode _newConfirmPassFocus;
  late FocusNode _twoFactorFocus;

  @override
  void initState() {
    super.initState();
    _oldPass = TextEditingController();
    _newPass = TextEditingController();
    _newPassConfirm = TextEditingController();
    _twoFactorCode = TextEditingController();
    _newPassConfirm.addListener(_onConfirmPassChanged);

    _newPassFocus = FocusNode();
    _newConfirmPassFocus = FocusNode();
    _twoFactorFocus = FocusNode();

    _loadUserInfo();
  }

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    _newPassConfirm.dispose();
    _twoFactorCode.dispose();
    _debounce?.cancel();

    _newPassFocus.dispose();
    _newConfirmPassFocus.dispose();
    _twoFactorFocus.dispose();
    super.dispose();
  }

  /// Lấy trạng thái IsTwoFactorEnabled từ SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final is2FA = prefs.getBool('is_two_factor_enabled') ?? false;
    if (mounted) {
      setState(() {
        _isTwoFactorEnabled = is2FA;
        _isLoadingUserInfo = false;
      });
    }
  }

  void _onConfirmPassChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_newPassConfirm.text.isNotEmpty) {
        _confirmPassKey.currentState!.validate();
      }
    });
  }

  /// Gọi API đổi mật khẩu (Atomic Request)
  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final dio = serviceLocator<Dio>();

      // Gom payload
      final payload = {
        'oldPassword': _oldPass.text.trim(),
        'newPassword': _newPass.text.trim(),
        'twoFactorCode': _isTwoFactorEnabled ? _twoFactorCode.text.trim() : null,
      };

      final response = await dio.post(
        ApiEndpoints.changePassword,
        data: payload,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Cập nhật token mới ngay lập tức vào flutter_secure_storage
        const secureStorage = FlutterSecureStorage();
        final newAccessToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await secureStorage.write(key: 'access_token', value: newAccessToken);
        }
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await secureStorage.write(key: 'refresh_token', value: newRefreshToken);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['message'] ?? 'Đổi mật khẩu thành công!',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';

      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is String) {
          errorMessage = data;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi không xác định: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F2F4),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D4ED8),
          ),
        ),
        title: Text(
          'Đổi mật khẩu',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
            letterSpacing: -0.3,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: _isLoadingUserInfo
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header mô tả ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF1D4ED8),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bảo mật tài khoản',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isTwoFactorEnabled
                                      ? 'Xác thực 2FA đang bật. Cần mã TOTP để đổi mật khẩu.'
                                      : 'Nhập mật khẩu cũ và mật khẩu mới để thay đổi.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Mật khẩu cũ ──
                    _buildLabel('Mật khẩu cũ'),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _obscureOldPass,
                      decoration: _buildInputDecoration(
                        hint: 'Nhập mật khẩu cũ',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: _buildToggleVisibility(
                          _obscureOldPass,
                          () => setState(() => _obscureOldPass = !_obscureOldPass),
                        ),
                      ),
                      validator: (value) => Validator.notEmpty(value, 'Mật khẩu cũ'),
                      controller: _oldPass,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_newPassFocus);
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Mật khẩu mới ──
                    _buildLabel('Mật khẩu mới'),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _obscureNewPass,
                      decoration: _buildInputDecoration(
                        hint: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                        icon: Icons.lock_reset_rounded,
                        suffixIcon: _buildToggleVisibility(
                          _obscureNewPass,
                          () => setState(() => _obscureNewPass = !_obscureNewPass),
                        ),
                      ),
                      validator: Validator.password,
                      controller: _newPass,
                      focusNode: _newPassFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_newConfirmPassFocus);
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Xác nhận mật khẩu mới ──
                    _buildLabel('Xác nhận mật khẩu mới'),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: _confirmPassKey,
                      obscureText: _obscureConfirmPass,
                      decoration: _buildInputDecoration(
                        hint: 'Nhập lại mật khẩu mới',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: _buildToggleVisibility(
                          _obscureConfirmPass,
                          () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        ),
                      ),
                      validator: (value) => Validator.confirmPassword(value, _newPass.text),
                      controller: _newPassConfirm,
                      focusNode: _newConfirmPassFocus,
                      textInputAction: _isTwoFactorEnabled ? TextInputAction.next : TextInputAction.done,
                      onFieldSubmitted: (value) {
                        if (_isTwoFactorEnabled) {
                          FocusScope.of(context).requestFocus(_twoFactorFocus);
                        }
                      },
                    ),

                    // ── Trường 2FA (chỉ hiển thị khi bật) ──
                    if (_isTwoFactorEnabled) ...[
                      const SizedBox(height: 20),
                      _buildLabel('Mã xác thực 2FA'),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          hint: 'Nhập mã 6 số từ Authenticator',
                          icon: Icons.shield_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mã 2FA';
                          }
                          if (value.trim().length != 6) {
                            return 'Mã 2FA phải đúng 6 chữ số';
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                            return 'Mã 2FA chỉ chứa chữ số';
                          }
                          return null;
                        },
                        controller: _twoFactorCode,
                        focusNode: _twoFactorFocus,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        textInputAction: TextInputAction.done,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 8,
                          color: AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Nút Submit ──
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          disabledBackgroundColor: const Color(0xFF1D4ED8).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isSubmitting ? null : _submitChangePassword,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Đổi mật khẩu',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildToggleVisibility(bool isObscured, VoidCallback onToggle) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}