import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/verify_cubit.dart';
import '../theme/azure_auth_theme.dart';

class OtpVerificationView extends StatefulWidget {
  final String title;
  final String email;
  final String buttonText;
  final VoidCallback onVerifySuccess;

  const OtpVerificationView({
    super.key,
    required this.title,
    required this.email,
    required this.buttonText,
    required this.onVerifySuccess,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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
    context.read<VerifyCubit>().verify(email: widget.email, code: otp);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyCubit, VerifyState>(
      listener: (context, state) {
        if (state is VerifySuccess) {
          widget.onVerifySuccess();
        } else if (state is ResendSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gửi mã xác nhận thành công')),
          );
        } else if (state is VerifyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AzureAuthTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AzureAuthTheme.azureBlue),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          title: Text('Kabo', style: AzureAuthTheme.headlineLg.copyWith(color: AzureAuthTheme.azureBlue)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: _buildVerifyCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyCard() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AzureAuthTheme.azureTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 40, color: AzureAuthTheme.azureBlue),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: AzureAuthTheme.headlineLg,
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AzureAuthTheme.bodyLg,
              children: [
                const TextSpan(text: 'Chúng tôi đã gửi mã xác nhận đến\nemail của bạn '),
                TextSpan(
                  text: widget.email,
                  style: AzureAuthTheme.bodyLg.copyWith(fontWeight: FontWeight.bold, color: AzureAuthTheme.textDeepGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildOtpRow(),
          const SizedBox(height: 48),
          BlocBuilder<VerifyCubit, VerifyState>(
            buildWhen: (previous, current) => 
                current is VerifyLoading || current is VerifyError || current is VerifyInitial,
            builder: (context, state) {
              final isLoading = state is VerifyLoading;
              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AzureAuthTheme.primaryContainer,
                    foregroundColor: AzureAuthTheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.buttonText, style: AzureAuthTheme.buttonText),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          BlocBuilder<VerifyCubit, VerifyState>(
            buildWhen: (previous, current) => 
                current is VerifyCountdown || current is VerifyCountdownDone || current is ResendLoading || current is ResendSuccess,
            builder: (context, state) {
              int seconds = 0;
              if (state is VerifyCountdown) {
                seconds = state.seconds;
              }
              final isResending = state is ResendLoading;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seconds > 0 ? Text(
                    'Hết hạn sau: ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                    style: AzureAuthTheme.bodyLg.copyWith(color: AzureAuthTheme.error),
                  ) : Text('Không nhận được mã? ', style: AzureAuthTheme.bodyLg),
                  if (seconds == 0)
                    TextButton(
                      onPressed: isResending ? null : () => context.read<VerifyCubit>().resend(email: widget.email),
                      style: TextButton.styleFrom(
                        foregroundColor: AzureAuthTheme.azureBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isResending ? 'Đang gửi lại...' : 'Gửi lại',
                        style: AzureAuthTheme.labelMd.copyWith(color: AzureAuthTheme.azureBlue),
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

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 50,
          height: 60,
          child: TextFormField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            autofocus: i == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AzureAuthTheme.headlineMd,
            inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100), 
                borderSide: const BorderSide(color: AzureAuthTheme.outlineVariant, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(color: AzureAuthTheme.outlineVariant, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(color: AzureAuthTheme.azureBlue, width: 1),
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
