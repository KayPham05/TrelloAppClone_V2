import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Image.asset(
                'lib/core/asset/logo_kabo.png',
                height: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 48),
              // Tagline
              Text(
                'Organize your\nworkflow visually',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4A4A),
                  height: 1.2,
                ),
              ),
              const Spacer(flex: 3),
              // Get Started Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E6FF1), Color(0xFF1B59D7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E6FF1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E6FF1), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E6FF1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Bottom links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const Text(' and '),
                  Text(
                    'Terms of Service',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
