import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selfcare/Widgets/bottomnavbar.dart';
import 'package:selfcare/providers/theme_provider.dart';
import 'package:selfcare/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: Scaffold(
        body: BottomNavScreen(),
      ),
    );
  }
}
