import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants/colors.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(_key, state == ThemeMode.dark);
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: Color(0xFFFCFCFC),
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primary.withOpacity(0.8),
    surface: Colors.white,
  ),
  cardColor: Colors.white,
  dividerColor: Colors.grey[200],
  textTheme: GoogleFonts.poppinsTextTheme(),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primary.withOpacity(0.8),
    surface: const Color(0xFF1E1E1E),
  ),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: Colors.grey[800],
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
);
