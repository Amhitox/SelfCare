import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../Models/study_session.dart';
import '../Models/achievement.dart';
import '../Services/storage_service.dart';

class StudyState {
  final List<StudySession> sessions;
  final Achievement achievement;
  const StudyState({required this.sessions, required this.achievement});

  StudyState copyWith({
    List<StudySession>? sessions,
    Achievement? achievement,
  }) =>
      StudyState(
        sessions: sessions ?? this.sessions,
        achievement: achievement ?? this.achievement,
      );
}

class StudyNotifier extends StateNotifier<StudyState> {
  StudyNotifier()
      : super(StudyState(
          sessions: [],
          achievement: Achievement(
            streak: 0,
            sessions: 0,
            focusTimeMinutes: 0,
            lastStudyDate:
                DateTime.now().subtract(const Duration(days: 365)),
          ),
        )) {
    _load();
  }

  static const _uuid = Uuid();
  static const _achievementKey = 'study_achievement';

  void _load() {
    final sessions = StorageService.studyBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final rawMap = StorageService.settingsBox.get(_achievementKey);
    Achievement achievement;
    if (rawMap is Map) {
      achievement =
          Achievement.fromMap(Map<String, dynamic>.from(rawMap));
    } else {
      achievement = Achievement(
        streak: 0,
        sessions: sessions.length,
        focusTimeMinutes:
            sessions.fold<int>(0, (acc, s) => acc + s.durationMinutes),
        lastStudyDate: sessions.isNotEmpty
            ? sessions.first.date
            : DateTime.now().subtract(const Duration(days: 365)),
      );
    }
    state = StudyState(sessions: sessions, achievement: achievement);
  }

  Future<StudySession> addSession(int durationMinutes,
      {String subject = 'General'}) async {
    final session = StudySession(
      id: _uuid.v4(),
      date: DateTime.now(),
      durationMinutes: durationMinutes,
      subject: subject,
    );
    await StorageService.studyBox.put(session.id, session);
    final updated = state.achievement.addSession(durationMinutes);
    await StorageService.settingsBox.put(_achievementKey, updated.toMap());
    _load();
    return session;
  }

  Future<void> deleteSession(StudySession session) async {
    await StorageService.studyBox.delete(session.id);
    _load();
  }

  int minutesThisWeek() {
    final start = DateTime.now().subtract(const Duration(days: 7));
    return state.sessions
        .where((s) => s.date.isAfter(start))
        .fold<int>(0, (acc, s) => acc + s.durationMinutes);
  }
}

final studyProvider =
    StateNotifierProvider<StudyNotifier, StudyState>((ref) => StudyNotifier());
