import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../init_dependencies.dart';
import '../cubit/forgot_password_cubit.dart';
import '../theme/azure_auth_theme.dart';
import '../widgets/auth_text_field_widget.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ForgotPasswordCubit>(),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<ForgotPasswordCubit>().sendOtp(email: _emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AzureAuthTheme.azureBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Kabo', style: AzureAuthTheme.headlineLg.copyWith(color: AzureAuthTheme.azureBlue)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: _buildForgotPasswordCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordCard() {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mã xác nhận đã được gửi đến email của bạn!')),
          );
          Navigator.pushReplacementNamed(context, '/reset-password', arguments: {
            'email': state.email,
          });
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AzureAuthTheme.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ForgotPasswordLoading;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('lib/core/asset/Background dùng cho forgot password.png', height: 200, fit: BoxFit.contain),
              const SizedBox(height: 32),
              Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: AzureAuthTheme.headlineLg,
              ),
              const SizedBox(height: 16),
              Text(
                'No worries. Enter your email address below and we\'ll send you instructions to reset your password.',
                textAlign: TextAlign.center,
                style: AzureAuthTheme.bodyLg,
              ),
              const SizedBox(height: 32),
              
              AuthTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'name@company.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Vui lòng nhập email hợp lệ' : null,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AzureAuthTheme.primaryContainer,
                    foregroundColor: AzureAuthTheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('RESET PASSWORD', style: AzureAuthTheme.buttonText),
                ),
              ),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                style: TextButton.styleFrom(foregroundColor: AzureAuthTheme.azureBlue),
                child: Text('BACK TO LOGIN', style: AzureAuthTheme.buttonText.copyWith(color: AzureAuthTheme.azureBlue)),
              ),
            ],
          ),
        );
      },
    );
  }
}
