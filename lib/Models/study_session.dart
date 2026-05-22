import 'package:hive/hive.dart';

class StudySession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final String subject;

  StudySession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    this.subject = 'General',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'subject': subject,
      };

  factory StudySession.fromMap(Map<dynamic, dynamic> map) => StudySession(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        durationMinutes: (map['durationMinutes'] as num).toInt(),
        subject: map['subject'] as String? ?? 'General',
      );
}

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 4;

  @override
  StudySession read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return StudySession.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer.writeMap(obj.toMap());
  }
}
