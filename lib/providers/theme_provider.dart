import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants/strings.dart';
import '../utils/theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
    (ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConsts.themeKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(AppConsts.themeKey, state == ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setBool(AppConsts.themeKey, mode == ThemeMode.dark);
  }
}

final lightTheme = AppTheme.light;
final darkTheme = AppTheme.dark;
