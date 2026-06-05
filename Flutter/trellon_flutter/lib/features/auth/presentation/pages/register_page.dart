import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../init_dependencies.dart';
import '../cubit/register_cubit.dart';
import '../theme/azure_auth_theme.dart';
import '../widgets/auth_text_field_widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RegisterCubit>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegisterCubit>().register(
      userName: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          Navigator.pushReplacementNamed(
            context,
            '/verify',
            arguments: state.user.email,
          );
        } else if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AzureAuthTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AzureAuthTheme.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480), // Desktop/Tablet constraint
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 48), 
                      _buildRegisterCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Text(
      'Kabo',
      style: AzureAuthTheme.headlineLg.copyWith(
        color: AzureAuthTheme.azureBlue,
      ),
    );
  }

  Widget _buildRegisterCard() {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        final isLoading = state is RegisterLoading;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AzureAuthTheme.outlineVariant, width: 1),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tạo tài khoản',
                  textAlign: TextAlign.center,
                  style: AzureAuthTheme.headlineLg,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tham gia cùng chúng tôi để làm việc hiệu quả hơn.',
                  textAlign: TextAlign.center,
                  style: AzureAuthTheme.bodyLg,
                ),
                const SizedBox(height: 32),
                
                AuthTextField(
                  controller: _usernameController,
                  labelText: 'Họ và tên',
                  hintText: 'Nhập họ và tên của bạn',
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 24),
                
                AuthTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Nhập địa chỉ email của bạn',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                ),
                const SizedBox(height: 24),
                
                AuthTextField(
                  controller: _passwordController,
                  labelText: 'Mật khẩu',
                  hintText: 'Tạo mật khẩu',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AzureAuthTheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu phải chứa ít nhất 6 ký tự' : null,
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 56, 
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AzureAuthTheme.primaryContainer,
                      foregroundColor: AzureAuthTheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('ĐĂNG KÝ', style: AzureAuthTheme.buttonText),
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: AzureAuthTheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('hoặc', style: AzureAuthTheme.bodyMd),
                    ),
                    Expanded(child: Divider(color: AzureAuthTheme.outlineVariant)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () {
                      // context.read<RegisterCubit>().signInWithGoogle() if available
                    },
                    icon: Image.asset('lib/core/asset/GoogleIcon.png', height: 24, width: 24),
                    label: Text(
                      'Đăng ký bằng Google',
                      style: AzureAuthTheme.buttonText.copyWith(color: AzureAuthTheme.azureBlue),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AzureAuthTheme.azureTint,
                      foregroundColor: AzureAuthTheme.azureBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã có tài khoản?', style: AzureAuthTheme.bodyLg),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: AzureAuthTheme.azureBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text('Đăng nhập', style: AzureAuthTheme.labelMd.copyWith(color: AzureAuthTheme.azureBlue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
