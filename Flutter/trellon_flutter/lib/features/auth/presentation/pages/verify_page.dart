import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 300; // 5 phút
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        return;
      }
      if (mounted) setState(() => _countdown--);
    });
  }

  String get _formatCountdown {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _fullOtp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    if (_fullOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 chữ số')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _countdown = 300;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isResending = false);
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi lại mã xác minh')),
    );
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _buildBody(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildLogo(),
            const SizedBox(height: 32),
            _buildVerifyCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.view_kanban_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 8),
        Text(
          'Trello',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'Xác minh địa chỉ email',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Info text
          Text(
            'Mã xác minh đã được gửi đến ',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          Text(
            'email của bạn.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Vui lòng kiểm tra hộp thư và nhập mã bên dưới.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 24),

          // OTP input grid
          _buildOtpGrid(),
          const SizedBox(height: 12),

          // Timer
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
              children: [
                const TextSpan(text: 'Mã sẽ hết hạn sau '),
                TextSpan(
                  text: _formatCountdown,
                  style: TextStyle(
                    color: _countdown < 60 ? AppColors.error : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Verify button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Xác minh', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 24),

          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),

          // Resend
          TextButton(
            onPressed: _isResending ? null : _handleResend,
            child: Text(
              _isResending ? 'Đang gửi lại...' : 'Gửi lại mã',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
            ),
          ),

          // Go to login
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(
              'Đã xác minh? Đăng nhập',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
          width: 44,
          height: 52,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKeyEvent(i, e),
            child: TextFormField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _onOtpDigitChanged(i, v),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: ['Chính sách bảo mật', 'Điều khoản dịch vụ', 'Cài đặt cookie']
                .map((t) => GestureDetector(
                      onTap: () {},
                      child: Text(
                        t,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Text('© 2024 Atlassian', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
