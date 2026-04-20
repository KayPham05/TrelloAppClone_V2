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
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      _email = args;
      // Kiểm tra trạng thái mã OTP ngay khi vào trang (tự động gửi lại nếu hết hạn)
      context.read<VerifyCubit>().checkOtpStatus(_email);
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyCubit, VerifyState>(
      listener: (context, state) {
        if (state is VerifySuccess) {
          Navigator.pushReplacementNamed(context, '/introduction');
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'Xác minh Email',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Mã xác minh đã được gửi đến:',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
          ),
          Text(
            _email,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildOtpGrid(),
          const SizedBox(height: 24),
          BlocBuilder<VerifyCubit, VerifyState>(
            buildWhen: (previous, current) => 
                current is VerifyLoading || current is VerifyError || current is VerifyInitial,
            builder: (context, state) {
              final isLoading = state is VerifyLoading;
              return SizedBox(
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
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<VerifyCubit, VerifyState>(
            buildWhen: (previous, current) => 
                current is VerifyCountdown || current is VerifyCountdownDone || current is ResendLoading || current is ResendSuccess,
            builder: (context, state) {
              int seconds = 0;
              if (state is VerifyCountdown) {
                seconds = state.seconds;
              }
              final isResending = state is ResendLoading;

              return Column(
                children: [
                  Text(
                    'Mã hết hạn sau: ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(color: AppColors.error, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: (isResending || seconds > 0) 
                      ? null 
                      : () => context.read<VerifyCubit>().resend(email: _email),
                    child: Text(
                      isResending ? 'Đang gửi...' : 'Gửi lại mã',
                      style: TextStyle(
                        color: (isResending || seconds > 0) ? AppColors.onSurfaceVariant : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 6 ô nhập OTP — mỗi ô là TextField độc lập (không dùng Form/TextFormField)
  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          child: TextFormField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
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
              fillColor: AppColors.surfaceContainerLow,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), 
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
              ),
            ),
            onChanged: (v) {
              if (v.length == 1 && i < 5) {
                _focusNodes[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _focusNodes[i - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }
}
