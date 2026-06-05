import 'package:apptreolon/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../init_dependencies.dart';
import '../cubit/login_cubit.dart';
import '../theme/azure_auth_theme.dart';
import '../widgets/auth_text_field_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<LoginCubit>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-cache the Google icon so it doesn't cause a jank on first render.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(const AssetImage('lib/core/asset/GoogleIcon.png'), context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty && _emailController.text.isEmpty) {
      _emailController.text = args;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          final localDataSource = serviceLocator<UserLocalDataSource>();
          final hasSeen = await localDataSource.getHasSeenIntroduction();
          if (!hasSeen) {
            if (context.mounted) Navigator.pushReplacementNamed(context, '/introduction');
          } else {
            if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (state is LoginRequiresVerification) {
          Navigator.pushReplacementNamed(context, '/verify', arguments: state.email);
        } else if (state is LoginAccountLocked) {
          Navigator.pushReplacementNamed(context, '/locked-account', arguments: state.email);
        } else if (state is LoginRequires2FA) {
          Navigator.pushReplacementNamed(
            context, 
            AppRoutes.twoFactorAuthPage, 
            arguments: {'userUId': state.userUId, 'email': state.email},
          );
        } else if (state is LoginError) {
          if (state.message.contains("đăng nhập bằng Google")) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Thông báo'),
                content: const Text('Tài khoản này được đăng nhập bằng Google. Vui lòng sử dụng nút "Đăng nhập bằng Google"'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AzureAuthTheme.error),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // Prevent the scaffold from resizing when the keyboard appears,
        // so Flutter doesn't re-layout the entire page on every IME frame update.
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 48), 
                      _buildLoginCard(),
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

  Widget _buildLoginCard() {
    // The form fields themselves never need to rebuild from BLoC state.
    // Only the buttons need isLoading — so BlocBuilder only wraps them.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(color: Colors.white),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Chào mừng trở lại', textAlign: TextAlign.left, style: AzureAuthTheme.headlineLg),
            const SizedBox(height: 8),
            Text(
              'Vui lòng điền thông tin để đăng nhập vào không gian làm việc.',
              textAlign: TextAlign.left,
              style: AzureAuthTheme.bodyLg,
            ),
            const SizedBox(height: 32),
            
            AuthTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Nhập email của bạn',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
            ),
            const SizedBox(height: 24),
            
            // Password field uses StatefulBuilder so toggling visibility
            // only rebuilds this subtree, not the whole card.
            StatefulBuilder(
              builder: (context, setFieldState) {
                return AuthTextField(
                  controller: _passwordController,
                  labelText: 'Mật khẩu',
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AzureAuthTheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setFieldState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: false,
                        onChanged: (v) {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Ghi nhớ đăng nhập trong 30 ngày', style: AzureAuthTheme.bodyLg),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: AzureAuthTheme.azureBlue,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Quên mật khẩu?', style: AzureAuthTheme.labelMd.copyWith(color: AzureAuthTheme.azureBlue)),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // BlocBuilder scoped only to the two buttons that care about isLoading.
            BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (prev, curr) =>
                  (prev is LoginLoading) != (curr is LoginLoading),
              builder: (context, state) {
                final isLoading = state is LoginLoading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AzureAuthTheme.primaryContainer,
                          foregroundColor: AzureAuthTheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('ĐĂNG NHẬP', style: AzureAuthTheme.buttonText),
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
                        onPressed: isLoading ? null : () => context.read<LoginCubit>().signInWithGoogle(),
                        icon: Image.asset('lib/core/asset/GoogleIcon.png', height: 24, width: 24),
                        label: Text(
                          'Đăng nhập bằng Google',
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
                  ],
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Chưa có tài khoản?', style: AzureAuthTheme.bodyLg),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                  style: TextButton.styleFrom(
                    foregroundColor: AzureAuthTheme.azureBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text('Đăng ký', style: AzureAuthTheme.labelMd.copyWith(color: AzureAuthTheme.azureBlue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
