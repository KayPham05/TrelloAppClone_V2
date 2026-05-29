import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../init_dependencies.dart';
import '../cubit/verify_cubit.dart';
import '../widgets/otp_verification_view.dart';

class VerifyPage extends StatelessWidget {
  const VerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String? ?? '';
    
    return BlocProvider(
      create: (context) => serviceLocator<VerifyCubit>()..checkOtpStatus(email),
      child: OtpVerificationView(
        title: 'Xác minh / Mở khóa Email',
        email: email,
        buttonText: 'Xác minh',
        onVerifySuccess: () {
          Navigator.pushReplacementNamed(context, '/introduction');
        },
      ),
    );
  }
}
