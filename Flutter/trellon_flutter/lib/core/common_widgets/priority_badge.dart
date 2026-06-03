import 'package:flutter/material.dart';

enum BadgeType { p1, p2, p3, fe, fullstack }

class PriorityBadge extends StatelessWidget {
  final BadgeType type;
  final String label;

  const PriorityBadge({
    super.key,
    required this.type,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case BadgeType.p1:
        bgColor = const Color(0xFFFFEBE6);
        textColor = const Color(0xFFCA3521);
        break;
      case BadgeType.p2:
        bgColor = const Color(0xFFDEEBFF);
        textColor = const Color(0xFF0052CC);
        break;
      case BadgeType.p3:
        bgColor = const Color(0xFFE3FCEF);
        textColor = const Color(0xFF006644);
        break;
      case BadgeType.fe:
        bgColor = const Color(0xFFDEEBFF);
        textColor = const Color(0xFF0052CC);
        break;
      case BadgeType.fullstack:
        bgColor = const Color(0xFFFFF0B3);
        textColor = const Color(0xFF172B4D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
