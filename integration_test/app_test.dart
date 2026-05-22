import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:selfcare/main.dart';
import 'package:selfcare/Screens/onboarding_screen.dart';
import 'package:selfcare/Screens/home_screen.dart';
import 'package:selfcare/Screens/task_screen.dart';
import 'package:selfcare/Screens/add_task_screen.dart';
import 'package:selfcare/Screens/mood_screen.dart';
import 'package:selfcare/Screens/selfcare_screen.dart';
import 'package:selfcare/Screens/settings_screen.dart';
import 'package:selfcare/Screens/study_screen.dart';
import 'package:selfcare/Services/storage_service.dart';
import 'package:selfcare/Services/notification_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await StorageService.init();
    await NotificationService.initialize();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await StorageService.tasksBox.clear();
    await StorageService.moodsBox.clear();
    await StorageService.journalBox.clear();
    await StorageService.studyBox.clear();
    await StorageService.settingsBox.clear();
  });

  testWidgets(
      'Full app smoke: onboarding → home → tasks → mood → settings → study',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    // Splash has a 1400ms delay then navigates.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ---- 1. Onboarding ----
    expect(find.byType(OnboardingScreen), findsOneWidget,
        reason: 'Expected to land on onboarding after splash');
    debugPrint('TEST: onboarding visible');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ---- 2. Home screen ----
    expect(find.byType(HomeScreen), findsOneWidget,
        reason: 'Expected Home after onboarding');
    expect(find.text("Today's Tasks"), findsOneWidget);
    debugPrint('TEST: home rendered');

    // ---- 3. Tasks tab + create a task ----
    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();
    expect(find.byType(TasksScreen), findsOneWidget);
    debugPrint('TEST: tasks tab rendered');

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTaskScreen), findsOneWidget);

    final titleField =
        find.widgetWithText(TextFormField, 'What do you want to do?');
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Write integration tests');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(TasksScreen), findsOneWidget);
    expect(find.text('Write integration tests'), findsWidgets);
    debugPrint('TEST: task created');

    // Toggle task complete by tapping its leftmost InkWell (the circle)
    final taskTitle = find.text('Write integration tests').first;
    final tileRow =
        find.ancestor(of: taskTitle, matching: find.byType(Row)).first;
    final toggleInk =
        find.descendant(of: tileRow, matching: find.byType(InkWell)).first;
    await tester.tap(toggleInk, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    debugPrint('TEST: task toggled');

    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Write integration tests'), findsWidgets);
    debugPrint('TEST: completed tab shows toggled task');

    // ---- 4. Self-care tab + mood check-in ----
    await tester.tap(find.text('Self-care').first);
    await tester.pumpAndSettle();
    expect(find.byType(SelfCareScreen), findsOneWidget);
    debugPrint('TEST: self-care tab rendered');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Check in').first);
    await tester.pumpAndSettle();
    expect(find.byType(MoodCheckInScreen), findsOneWidget);

    await tester.tap(find.text('Great'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Grateful'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save mood'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(SelfCareScreen), findsOneWidget);
    debugPrint('TEST: mood saved, back on self-care');

    // ---- 5. Settings ----
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    debugPrint('TEST: dark mode toggled');

    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---- 6. Study tab ----
    await tester.tap(find.text('Study').first);
    await tester.pumpAndSettle();
    expect(find.byType(StudyScreen), findsOneWidget);
    debugPrint('TEST: study tab rendered');

    // ---- 7. Back to Home ----
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    debugPrint('TEST: home tab rendered after full loop');

    debugPrint('TEST: ✅ ALL FLOWS PASSED');
  });
}
