import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFEC6E9F);
  static const Color primaryDark = Color(0xFFD05484);
  static const Color secondary = Color(0xFFF8A1C4);
  static const Color accent = Color(0xFFFF5A8F);
  static const Color background = Color(0xFFFFF5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D1B2A);
  static const Color textSecondary = Color(0xFF8A6B7C);
  static const Color textMuted = Color(0xFFB8A0AE);
  static const Color border = Color(0xFFF0DCE5);
  static const Color success = Color(0xFF6FCF97);
  static const Color warning = Color(0xFFF2C94C);
  static const Color error = Color(0xFFEB5757);
  static const Color info = Color(0xFF56CCF2);

  static const Color gradient1 = Color(0xFFEC6E9F);
  static const Color gradient2 = Color(0xFFFF8AB8);

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [gradient1, gradient2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class DarkAppColors {
  DarkAppColors._();
  static const Color primary = Color(0xFFFF8AB8);
  static const Color background = Color(0xFF181018);
  static const Color surface = Color(0xFF22161F);
  static const Color card = Color(0xFF2A1B26);
  static const Color textPrimary = Color(0xFFFFE8F0);
  static const Color textSecondary = Color(0xFFCE9DB4);
  static const Color border = Color(0xFF3A2330);
}
