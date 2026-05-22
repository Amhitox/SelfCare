import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Services/storage_service.dart';
import 'Services/notification_service.dart';
import 'Services/ads_service.dart';
import 'providers/theme_provider.dart';
import 'providers/app_state_provider.dart';
import 'Screens/splash_screen.dart';
import 'Screens/onboarding_screen.dart';
import 'Widgets/bottomnavbar.dart';
import 'utils/constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await StorageService.init();
  await NotificationService.initialize();
  // Fire and forget — must not block app start.
  AdsService.instance.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: theme,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => BottomNavScreen(),
      },
    );
  }
}

class AppEntry extends ConsumerWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(onboardingProvider);
    return completed ? BottomNavScreen() : const OnboardingScreen();
  }
}
