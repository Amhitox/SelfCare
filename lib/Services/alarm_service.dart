import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:selfcare/Models/task.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(initSettings);

    tz.initializeTimeZones();
  }

  static Future<void> scheduleTaskAlarm(Task task) async {
    final int alarmId = task.id.hashCode;

    final DateTime scheduledDateTime = DateTime(
      task.createdAt.year,
      task.createdAt.month,
      task.createdAt.day,
      task.dueTime.hour,
      task.dueTime.minute,
    );

    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledDateTime, tz.local);

    await AndroidAlarmManager.oneShotAt(
      tzScheduledTime,
      alarmId,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelTaskAlarm(Task task) async {
    final int alarmId = task.id.hashCode;
    await AndroidAlarmManager.cancel(alarmId);
  }
}

void alarmCallback() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'task_reminders',
    'Task Reminders',
    channelDescription: 'Notifications for task reminders',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('windowson'),
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await AlarmService._notificationsPlugin.show(
    0,
    'Task Reminder',
    'It\'s time for your scheduled task!',
    notificationDetails,
  );
}
