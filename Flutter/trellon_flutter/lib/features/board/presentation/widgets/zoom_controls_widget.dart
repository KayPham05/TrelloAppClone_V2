import 'package:flutter/material.dart';

class ZoomControlsWidget extends StatelessWidget {
  final bool isDetailMode;
  final VoidCallback onToggleZoom;

  const ZoomControlsWidget({
    super.key,
    required this.isDetailMode,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleZoom,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF90CA4B), // Trello Mobile Lime Green
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isDetailMode ? Icons.zoom_out_rounded : Icons.zoom_in_rounded,
          color: Colors.black87,
          size: 28,
        ),
      ),
    );
  }
}
