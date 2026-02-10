import 'package:flutter/material.dart';

class AppColors {
  static const Color brandTeal = Color(0xFF19B4A5);
  static const Color brandBlue = Color(0xFF1B4DFF);
  static const Color brandNavy = Color(0xFF0B1638);
  static const Color ink = Color(0xFF0E1726);
  static const Color mist = Color(0xFFF3F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE1E6EF);
  static const Color subtle = Color(0xFFEEF2F8);
  static const Color success = Color(0xFF1F8F5F);
  static const Color warning = Color(0xFFEB8C2A);
  static const Color danger = Color(0xFFE04F5F);

  static const LinearGradient backdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1638),
      Color(0xFF123B7A),
      Color(0xFF0D6A7A),
    ],
  );
}
