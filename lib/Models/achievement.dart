class Achievement {
  final int streak;
  final int sessions;
  final int focusTimeMinutes;
  final DateTime lastStudyDate;

  Achievement({
    required this.streak,
    required this.sessions,
    required this.focusTimeMinutes,
    required this.lastStudyDate,
  });

  String get totalFocusTime {
    final hours = focusTimeMinutes ~/ 60;
    final minutes = focusTimeMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
        streak: (map['streak'] as num?)?.toInt() ?? 0,
        sessions: (map['sessions'] as num?)?.toInt() ?? 0,
        focusTimeMinutes: (map['focusTimeMinutes'] as num?)?.toInt() ?? 0,
        lastStudyDate: DateTime.parse(
            map['lastStudyDate'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toMap() => {
        'streak': streak,
        'sessions': sessions,
        'focusTimeMinutes': focusTimeMinutes,
        'lastStudyDate': lastStudyDate.toIso8601String(),
      };

  Achievement copyWith({
    int? streak,
    int? sessions,
    int? focusTimeMinutes,
    DateTime? lastStudyDate,
  }) =>
      Achievement(
        streak: streak ?? this.streak,
        sessions: sessions ?? this.sessions,
        focusTimeMinutes: focusTimeMinutes ?? this.focusTimeMinutes,
        lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      );

  Achievement updateStreak() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (lastStudyDate.year == today.year &&
        lastStudyDate.month == today.month &&
        lastStudyDate.day == today.day) {
      return this;
    }
    if (lastStudyDate.year == yesterday.year &&
        lastStudyDate.month == yesterday.month &&
        lastStudyDate.day == yesterday.day) {
      return copyWith(streak: streak + 1);
    }
    return copyWith(streak: 1);
  }

  Achievement addSession(int durationMinutes) => copyWith(
        sessions: sessions + 1,
        focusTimeMinutes: focusTimeMinutes + durationMinutes,
        lastStudyDate: DateTime.now(),
      ).updateStreak();
}
