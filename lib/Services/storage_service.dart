import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/task.dart';
import '../Models/mood.dart';
import '../Models/journal_entry.dart';
import '../Models/study_session.dart';
import '../utils/constants/strings.dart';

class StorageService {
  StorageService._();

  static late Box<Task> tasksBox;
  static late Box<Mood> moodsBox;
  static late Box<JournalEntry> journalBox;
  static late Box<StudySession> studyBox;
  static late Box settingsBox;
  static late SharedPreferences prefs;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(MoodAdapter());
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(JournalEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(StudySessionAdapter());
    }

    tasksBox = await Hive.openBox<Task>(AppConsts.hiveTasksBox);
    moodsBox = await Hive.openBox<Mood>(AppConsts.hiveMoodsBox);
    journalBox = await Hive.openBox<JournalEntry>(AppConsts.hiveJournalBox);
    studyBox = await Hive.openBox<StudySession>(AppConsts.hiveStudyBox);
    settingsBox = await Hive.openBox(AppConsts.hiveSettingsBox);

    prefs = await SharedPreferences.getInstance();
  }
}
