import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../init_dependencies.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_endpoints.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _2faController = TextEditingController();
  
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _step = 1; // 1: Input Email/Pass, 2: 2FA, 3: OTP

  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  void _startCountdown({int seconds = 30}) {
    setState(() {
      _secondsRemaining = seconds;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    _2faController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailAndPass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = serviceLocator<Dio>();
      final response = await dio.post(
        ApiEndpoints.checkChangeEmail,
        data: {
          'newEmail': _newEmailController.text.trim(),
          'currentPassword': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final is2FAEnabled = response.data['is2FAEnabled'] ?? false;
        if (is2FAEnabled) {
          setState(() => _step = 2);
        } else {
          await _sendOtp();
        }
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? 'Lỗi không xác định.');
    } catch (e) {
      _showError('Đã xảy ra lỗi.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);

    try {
      final dio = serviceLocator<Dio>();
      final response = await dio.post(
        ApiEndpoints.sendChangeEmailOtp,
        data: {
          'newEmail': _newEmailController.text.trim(),
          'currentPassword': _passwordController.text,
          'twoFactorCode': _step == 2 ? _2faController.text.trim() : null,
        },
      );

      if (response.statusCode == 200) {
        setState(() => _step = 3);
        _startCountdown(seconds: 30);
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? 'Lỗi xác thực.');
    } catch (e) {
      _showError('Đã xảy ra lỗi.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmOtp() async {
    final otpCode = _otpControllers.map((c) => c.text).join('');
    if (otpCode.length != 6) {
      _showError('Vui lòng nhập đủ 6 số OTP');
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final dio = serviceLocator<Dio>();
      final response = await dio.post(
        ApiEndpoints.confirmChangeEmail,
        data: {
          'newEmail': _newEmailController.text.trim(),
          'otpCode': otpCode,
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _newEmailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi email thành công!')),
          );
          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? 'Lỗi xác thực.');
    } catch (e) {
      _showError('Đã xảy ra lỗi.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Lỗi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D4ED8),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đổi Email Liên Kết',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_step == 1) ...[
                  Text(
                    'Vui lòng nhập địa chỉ email mới và mật khẩu hiện tại để tiếp tục.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Email mới',
                    hintText: "Nhập địa chỉ email mới",
                    controller: _newEmailController,
                    icon: Icons.email_outlined,
                    validator: (val) =>
                        val == null || val.isEmpty || !val.contains('@')
                        ? 'Email không hợp lệ'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Mật khẩu hiện tại',
                    hintText: "Nhập mật khẩu hiện tại",
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Vui lòng nhập mật khẩu'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  _buildButton('Tiếp tục', _checkEmailAndPass),
                ] else if (_step == 2) ...[
                  Text(
                    'Vui lòng nhập mã 2FA từ ứng dụng Authenticator của bạn.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Mã 2FA',
                    hintText: 'Nhập mã 2FA',
                    controller: _2faController,
                    icon: Icons.security,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  _buildButton('Xác thực', _sendOtp),
                ] else if (_step == 3) ...[
                  Text(
                    'Một mã OTP đã được gửi đến email mới của bạn. Vui lòng nhập để xác nhận.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOtpRow(),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Chưa nhận được mã? ',
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: _secondsRemaining > 0
                                ? 'Gửi lại sau ${_secondsRemaining}s'
                                : 'Gửi lại mã',
                            style: GoogleFonts.inter(
                              color: _secondsRemaining > 0
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _secondsRemaining > 0
                                ? null
                                : (TapGestureRecognizer()..onTap = _sendOtp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildButton('Xác nhận & Hoàn tất', _confirmOtp),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
  }) {
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
          decoration: InputDecoration(
            hintText: hintText ?? '',
            prefixIcon: Icon(icon, color: AppColors.outline),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant),
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

  Widget _buildOtpRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mã OTP (gửi về email mới)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 45,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    if (_otpControllers[i].text.isEmpty && i > 0) {
                      _otpFocusNodes[i - 1].requestFocus();
                    }
                  }
                },
                child: TextFormField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  autofocus: i == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: GoogleFonts.inter(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.length == 1 && i < 5) {
                      _otpFocusNodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _otpFocusNodes[i - 1].requestFocus();
                    }
                    setState(() {});
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}
