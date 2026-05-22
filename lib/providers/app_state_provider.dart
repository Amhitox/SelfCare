import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants/strings.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) => OnboardingNotifier());

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConsts.onboardingKey) ?? false;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    state = true;
    await prefs.setBool(AppConsts.onboardingKey, true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    state = false;
    await prefs.setBool(AppConsts.onboardingKey, false);
  }
}

final premiumThemeProvider =
    StateNotifierProvider<PremiumThemeNotifier, bool>((ref) => PremiumThemeNotifier());

class PremiumThemeNotifier extends StateNotifier<bool> {
  PremiumThemeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConsts.premiumThemeKey) ?? false;
  }

  Future<void> unlock() async {
    final prefs = await SharedPreferences.getInstance();
    state = true;
    await prefs.setBool(AppConsts.premiumThemeKey, true);
  }
}

final extraStatsProvider =
    StateNotifierProvider<ExtraStatsNotifier, bool>((ref) => ExtraStatsNotifier());

class ExtraStatsNotifier extends StateNotifier<bool> {
  ExtraStatsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConsts.extraStatsKey) ?? false;
  }

  Future<void> unlock() async {
    final prefs = await SharedPreferences.getInstance();
    state = true;
    await prefs.setBool(AppConsts.extraStatsKey, true);
  }
}
