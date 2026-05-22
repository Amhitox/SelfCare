import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../Models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get _supported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static Future<void> initialize() async {
    if (!_supported || _initialized) return;
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    if (!_supported) return;
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleTaskReminder(Task task) async {
    if (!_supported) return;
    try {
      if (!_initialized) await initialize();
      final scheduled = tz.TZDateTime.from(task.dueDateTime, tz.local);
      // Skip if scheduled time has already passed or is within 30 seconds —
      // the OS rejects very-near alarms on some Android builds.
      if (scheduled
          .isBefore(tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30)))) {
        return;
      }

      await _plugin.zonedSchedule(
        task.id.hashCode,
        'Task reminder',
        task.title,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Reminders for your scheduled tasks',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e, st) {
      // Never let notification scheduling break task save flow.
      debugPrint('scheduleTaskReminder failed: $e\n$st');
    }
  }

  static Future<void> cancelTaskReminder(Task task) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(task.id.hashCode);
    } catch (e) {
      debugPrint('cancelTaskReminder failed: $e');
    }
  }

  static Future<void> showNow(String title, String body) async {
    if (!_supported) return;
    try {
      if (!_initialized) await initialize();
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'general',
            'General',
            importance: Importance.defaultImportance,
          ),
        ),
      );
    } catch (e) {
      debugPrint('showNow failed: $e');
    }
  }
}
