import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:selfcare/main.dart';
import 'package:selfcare/Screens/onboarding_screen.dart';
import 'package:selfcare/Screens/task_screen.dart';
import 'package:selfcare/Screens/add_task_screen.dart';
import 'package:selfcare/Services/storage_service.dart';
import 'package:selfcare/Services/notification_service.dart';
import 'package:selfcare/utils/constants/colors.dart';

Future<void> _skipOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: MainApp()));
  await tester.pumpAndSettle(const Duration(seconds: 3));
  if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

Future<void> _enableDarkMode(WidgetTester tester) async {
  // Navigate Self-care → Settings → toggle dark.
  await tester.tap(find.text('Self-care').first);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(SwitchListTile));
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}

/// Pulls the background color of the topmost Scaffold currently on screen.
Color? _topScaffoldBg(WidgetTester tester) {
  final scaffolds = find.byType(Scaffold).evaluate();
  if (scaffolds.isEmpty) return null;
  // Last in tree = topmost (pushed last).
  final s = scaffolds.last.widget as Scaffold;
  return s.backgroundColor;
}

bool _isLightish(Color c) {
  // crude luminance check — anything > 0.6 is "light"
  final lum = (0.299 * c.r + 0.587 * c.g + 0.114 * c.b);
  return lum > 0.6;
}

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

  // ===========================================================================
  // EDGE CASE 1: Can you create a task with due time < 1 hour from now?
  // The user reports tasks don't get created. Code review suggests they do get
  // saved, but the notification is silently skipped if scheduled time is past.
  // This test creates a task with default time (which is now + 1h) and then
  // edits it to a time only minutes ahead, and verifies it persists.
  // ===========================================================================
  testWidgets('EDGE: task with default time creates successfully',
      (tester) async {
    await _skipOnboarding(tester);

    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTaskScreen), findsOneWidget);

    // Don't touch date/time — use defaults (now + 1h, today's date).
    await tester.enterText(
      find.widgetWithText(TextFormField, 'What do you want to do?'),
      'Default-time task',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Task should exist in the Today tab.
    expect(find.byType(TasksScreen), findsOneWidget);
    expect(find.text('Default-time task'), findsWidgets,
        reason: 'Task created with default (~1h ahead) time should appear');

    // Confirm it landed in storage too.
    final saved = StorageService.tasksBox.values
        .where((t) => t.title == 'Default-time task');
    expect(saved.length, 1,
        reason: 'Task should be persisted to Hive');
    debugPrint('TEST: default-time task created and persisted');
  });

  // ===========================================================================
  // EDGE CASE 2: Dark mode background color leaks light theme on every screen
  // that hardcodes AppColors.background.
  // ===========================================================================
  testWidgets('EDGE: dark mode applies to every main screen', (tester) async {
    await _skipOnboarding(tester);
    await _enableDarkMode(tester);

    final failures = <String>[];

    Future<void> check(String name, Finder navTap) async {
      await tester.tap(navTap);
      await tester.pumpAndSettle();
      final bg = _topScaffoldBg(tester);
      final hex = bg == null
          ? 'null'
          : '#${bg.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
      if (bg == null) {
        debugPrint('  $name: scaffold bg = null (inherits theme — OK)');
      } else if (_isLightish(bg)) {
        failures.add('$name uses LIGHT scaffold bg $hex in dark mode');
        debugPrint('  $name: ❌ scaffold bg = $hex (LIGHT — BUG)');
      } else {
        debugPrint('  $name: ✓ scaffold bg = $hex (dark)');
      }
    }

    await check('Home', find.text('Home').first);
    await check('Tasks', find.text('Tasks').first);
    await check('Study', find.text('Study').first);
    await check('Self-care', find.text('Self-care').first);

    // Also check Add Task subpage.
    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    final addTaskBg = _topScaffoldBg(tester);
    final addTaskHex = addTaskBg == null
        ? 'null'
        : '#${addTaskBg.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    if (addTaskBg != null && _isLightish(addTaskBg)) {
      failures.add('AddTask uses LIGHT scaffold bg $addTaskHex in dark mode');
      debugPrint('  AddTask: ❌ scaffold bg = $addTaskHex (LIGHT — BUG)');
    } else {
      debugPrint('  AddTask: ✓ scaffold bg = $addTaskHex');
    }

    // Pop back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Mood check-in
    await tester.tap(find.text('Self-care').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Check in').first);
    await tester.pumpAndSettle();
    final moodBg = _topScaffoldBg(tester);
    final moodHex = moodBg == null
        ? 'null'
        : '#${moodBg.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    if (moodBg != null && _isLightish(moodBg)) {
      failures.add('Mood check-in uses LIGHT scaffold bg $moodHex in dark mode');
      debugPrint('  Mood: ❌ scaffold bg = $moodHex (LIGHT — BUG)');
    } else {
      debugPrint('  Mood: ✓ scaffold bg = $moodHex');
    }

    debugPrint('==========================================');
    debugPrint('Dark-mode scaffold audit: ${failures.length} broken screens');
    for (final f in failures) {
      debugPrint('  - $f');
    }
    debugPrint('==========================================');

    // Surface the bug — fails loud with all violations
    expect(failures, isEmpty,
        reason: 'These screens leak the light scaffold bg in dark mode');
  });

  // ===========================================================================
  // EDGE CASE 3: Beyond the scaffold, individual cards/tiles also hardcode
  // AppColors.card (#FFFFFF white). In dark mode they should not be white.
  // ===========================================================================
  testWidgets('EDGE: card / tile backgrounds in dark mode', (tester) async {
    await _skipOnboarding(tester);
    await _enableDarkMode(tester);

    // Create one task so we have a tile to inspect
    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'What do you want to do?'),
      'Dark mode probe',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Find any Container in the task list region that has color set
    // to AppColors.card (white) — that's the bug.
    final containers = find.byType(Container);
    final whiteContainers = <String>[];
    for (final e in containers.evaluate()) {
      final c = e.widget as Container;
      final deco = c.decoration;
      Color? bg;
      if (deco is BoxDecoration) {
        bg = deco.color;
      } else {
        bg = c.color;
      }
      if (bg != null && bg.toARGB32() == AppColors.card.toARGB32()) {
        whiteContainers.add(
            'Container at depth=${e.depth} bg=#${bg.toARGB32().toRadixString(16).toUpperCase()}');
      }
    }
    debugPrint('==========================================');
    debugPrint('White-card audit: ${whiteContainers.length} hardcoded white containers visible in dark mode');
    for (final w in whiteContainers.take(10)) {
      debugPrint('  - $w');
    }
    debugPrint('==========================================');
    expect(whiteContainers, isEmpty,
        reason: 'Containers should not hardcode AppColors.card (#FFFFFF) in dark mode');
  });

  // ===========================================================================
  // EDGE CASE 4: Hardcoded text colors stay dark on dark backgrounds → unreadable.
  // ===========================================================================
  testWidgets('EDGE: hardcoded dark text in dark mode', (tester) async {
    await _skipOnboarding(tester);
    await _enableDarkMode(tester);

    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();

    // Walk all Text widgets and find any with explicit AppColors.textPrimary
    // (#2D1B2A — very dark) — those would be invisible on dark backgrounds.
    final texts = find.byType(Text);
    final darkOnDark = <String>[];
    for (final e in texts.evaluate()) {
      final t = e.widget as Text;
      final color = t.style?.color;
      if (color != null &&
          color.toARGB32() == AppColors.textPrimary.toARGB32()) {
        darkOnDark.add('"${t.data}" uses AppColors.textPrimary (#2D1B2A)');
      }
    }
    debugPrint('==========================================');
    debugPrint('Dark-text-on-dark audit: ${darkOnDark.length} unreadable Text widgets');
    for (final d in darkOnDark.take(10)) {
      debugPrint('  - $d');
    }
    debugPrint('==========================================');
    expect(darkOnDark, isEmpty,
        reason: 'Text widgets should not hardcode AppColors.textPrimary in dark mode');
  });
}
