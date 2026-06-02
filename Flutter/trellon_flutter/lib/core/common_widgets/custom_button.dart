import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Pill shape
              ),
              backgroundColor: isDestructive ? const Color(0xFFCA3521) : const Color(0xFF0052CC),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
           foregroundColor: isDestructive ? const Color(0xFFCA3521) : const Color(0xFF0052CC),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: isDestructive ? const Color(0xFFCA3521) : const Color(0xFF0052CC),
          ),
        ),
      );
    }
  }
}
