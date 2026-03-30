import 'package:flutter/material.dart';

class ColorUtils {
  static Color hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
