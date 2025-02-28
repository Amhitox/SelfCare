import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Models/achievement.dart';

class AchievementService {
  static const String _achievementKey = 'user_achievements';

  static Future<Achievement> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementJson = prefs.getString(_achievementKey);

    if (achievementJson == null) {
      return Achievement(
        streak: 0,
        sessions: 0,
        focusTimeMinutes: 0,
        lastStudyDate: DateTime.now(),
      );
    }

    return Achievement.fromMap(json.decode(achievementJson));
  }

  static Future<void> saveAchievements(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_achievementKey, json.encode(achievement.toMap()));
  }

  static Future<Achievement> addStudySession(int durationMinutes) async {
    final achievement = await getAchievements();
    final updatedAchievement = achievement.addSession(durationMinutes);
    await saveAchievements(updatedAchievement);
    return updatedAchievement;
  }
}
