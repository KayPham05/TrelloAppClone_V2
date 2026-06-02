import 'package:flutter/material.dart';
import '../theme/azure_auth_theme.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('lib/core/asset/Background dùng cho succesfull page.png', height: 200, fit: BoxFit.contain),
                    const SizedBox(height: 32),
                    Text(
                      'Success',
                      textAlign: TextAlign.center,
                      style: AzureAuthTheme.headlineLg,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your password has been successfully updated.',
                      textAlign: TextAlign.center,
                      style: AzureAuthTheme.bodyLg,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AzureAuthTheme.primaryContainer,
                          foregroundColor: AzureAuthTheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text('CONTINUE', style: AzureAuthTheme.buttonText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
