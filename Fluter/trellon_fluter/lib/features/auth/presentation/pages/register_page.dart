import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/register_usecase.dart';
import '../cubit/register_cubit.dart';
import '../widgets/auth_text_field_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
                'Lỗi đăng ký', style: TextStyle(color: AppColors.error)),
            content: Text(
                message, style: const TextStyle(color: AppColors.textWhite)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                    'Đóng', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RegisterCubit(
            registerUseCase: RegisterUseCase(
              AuthRepositoryImpl(DioClient().instance),
            ),
          ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
                Icons.arrow_back_ios_new, color: AppColors.textPrimary,
                size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              // Đăng ký xong, BE gửi mã, chuyển luôn sang màn Verify
              Navigator.pushReplacementNamed(
                  context,
                  '/verify',
                  arguments: {'email': _emailController.text.trim()}
              );
            } else if (state is RegisterError) {
              _showErrorDialog(state.message);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Tham gia Trellon',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bắt đầu tổ chức công việc của bạn một cách chuyên nghiệp',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      AuthTextFieldWidget(
                        controller: _userNameController,
                        label: 'Tên đăng nhập',
                        hint: 'Nhập tên của bạn',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập tên đăng nhập';
                          if (value.length < 3)
                            return 'Tên đăng nhập phải ít nhất 3 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextFieldWidget(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextFieldWidget(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        hint: 'Ít nhất 6 ký tự',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons
                                .visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() =>
                              _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập mật khẩu';
                          if (value.length < 1)
                            return 'Mật khẩu phải ít nhất 6 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextFieldWidget(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu',
                        hint: 'Nhập lại mật khẩu',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() =>
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text)
                            return 'Mật khẩu không khớp';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      if (state is RegisterLoading)
                        const Center(child: CircularProgressIndicator(
                            color: AppColors.primary))
                      else
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<RegisterCubit>().register(
                                userName: _userNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Đã có tài khoản? ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}