import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selfcare/Services/alarm_service.dart';
import 'package:selfcare/Widgets/bottomnavbar.dart';
import 'package:selfcare/providers/theme_provider.dart';
import 'package:selfcare/Screens/journal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AlarmService.initialize();
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
      home: BottomNavScreen(),
    );
  }
}
