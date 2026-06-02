import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../init_dependencies.dart';
import '../cubit/forgot_password_cubit.dart';
import '../theme/azure_auth_theme.dart';
import '../widgets/auth_text_field_widget.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<ForgotPasswordCubit>(),
      child: const ResetPasswordView(),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('email')) {
      _email = args['email'];
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      context.read<ForgotPasswordCubit>().resetPassword(
            email: _email,
            otp: _otpController.text.trim(),
            newPassword: _passwordController.text.trim(),
          );
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
                child: _buildResetCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetCard() {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordResetSuccess) {
          Navigator.pushReplacementNamed(context, '/success');
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
              Text(
                'Reset Password',
                textAlign: TextAlign.center,
                style: AzureAuthTheme.headlineLg,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit confirmation code from your email and your new password.',
                textAlign: TextAlign.center,
                style: AzureAuthTheme.bodyLg,
              ),
              const SizedBox(height: 32),
              
              AuthTextField(
                controller: _otpController,
                labelText: 'Confirmation Code (OTP)',
                hintText: 'Enter 6-digit code',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter code' : null,
              ),
              const SizedBox(height: 24),
              
              AuthTextField(
                controller: _passwordController,
                labelText: 'New Password',
                hintText: 'Enter your new password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AzureAuthTheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AzureAuthTheme.primaryContainer,
                    foregroundColor: AzureAuthTheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('CONFIRM PASSWORD', style: AzureAuthTheme.buttonText),
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
