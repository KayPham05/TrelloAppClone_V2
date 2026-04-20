import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../cubit/verify_cubit.dart';

class VerifyPage extends StatelessWidget {
  const VerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<VerifyCubit>(),
      child: const VerifyView(),
    );
  }
}

class VerifyView extends StatefulWidget {
  const VerifyView({super.key});

  @override
  State<VerifyView> createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  // Dùng List controller & focusNode riêng biệt cho từng ô OTP
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _email;
  bool _emailLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_emailLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _email = args;
        _emailLoaded = true;
        // Bắt đầu đếm ngược 5 phút khi vào trang
        context.read<VerifyCubit>().startCountdown(seconds: 300);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _fullOtp => _controllers.map((c) => c.text).join();

  void _handleVerify() {
    final otp = _fullOtp;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số')),
      );
      return;
    }
    context.read<VerifyCubit>().verify(email: _email, code: otp);
  }

  /// Chuyển focus sang ô kế tiếp khi nhập, hoặc ô trước khi xóa
  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Nhập xong, nhảy sang ô tiếp theo
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Ô cuối: ẩn bàn phím
        _focusNodes[index].unfocus();
      }
    }
    setState(() {});
  }

  /// Xử lý phím Backspace khi controller rỗng → quay về ô trước
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
    return BlocListener<VerifyCubit, VerifyState>(
      listener: (context, state) {
        if (state is VerifySuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is ResendSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi lại mã xác minh thành công')),
          );
        } else if (state is VerifyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildVerifyCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyCard() {
    return BlocBuilder<VerifyCubit, VerifyState>(
      builder: (context, state) {
        final isLoading = state is VerifyLoading;
        final isResending = state is ResendLoading;

        // Tính seconds còn lại
        int seconds = 0;
        if (state is VerifyCountdown) {
          seconds = state.seconds;
        }
        // VerifyCountdownDone → seconds = 0

        // Nút "Gửi lại mã" chỉ bật khi còn dưới 4 phút (< 240 giây)
        // VÀ đồng hồ đã kết thúc (VerifyCountdownDone, tức seconds == 0)
        final canResend = !isResending && seconds == 0;

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              // ─── Tiêu đề ───
              Text(
                'Xác minh Email',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ─── Email ───
              Text(
                'Mã xác minh đã được gửi đến:',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
              ),
              Text(
                _emailLoaded ? _email : '',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // ─── 6 ô OTP ───
              _buildOtpRow(),
              const SizedBox(height: 24),

              // ─── Nút Xác minh ───
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Xác minh'),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Đồng hồ đếm ngược ───
              Text(
                seconds > 0
                    ? 'Mã hết hạn sau: ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
                    : 'Mã đã hết hạn',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),

              // ─── Nút Gửi lại mã ───
              // Chỉ bật khi mã đã hết hạn (seconds == 0)
              TextButton(
                onPressed: canResend
                    ? () {
                        context.read<VerifyCubit>().resend(email: _email);
                      }
                    : () {
                        // Vẫn còn thời gian → thông báo
                        if (seconds >= 240) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Chỉ có thể gửi lại mã khi còn dưới 4 phút',
                              ),
                            ),
                          );
                        }
                      },
                child: Text(
                  isResending ? 'Đang gửi...' : 'Gửi lại mã',
                  style: TextStyle(
                    color: canResend
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),

              const Divider(height: 24),

              // ─── Nút Trở lại ───
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: const Text('Trở lại đăng nhập'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: BorderSide(color: AppColors.onSurfaceVariant.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 6 ô nhập OTP — mỗi ô là TextField độc lập (không dùng Form/TextFormField)
  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 44,
            height: 52,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKeyEvent(i, event),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.onSurfaceVariant.withAlpha(60),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (v) => _onOtpChanged(i, v),
              ),
            ),
          ),
        );
      }),
    );
  }
}
