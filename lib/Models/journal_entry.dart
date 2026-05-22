import 'package:hive/hive.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String mood;

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.mood = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'mood': mood,
      };

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        title: map['title'] as String,
        content: map['content'] as String,
        mood: map['mood'] as String? ?? '',
      );

  JournalEntry copyWith({
    String? title,
    String? content,
    String? mood,
  }) =>
      JournalEntry(
        id: id,
        date: date,
        title: title ?? this.title,
        content: content ?? this.content,
        mood: mood ?? this.mood,
      );
}

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 3;

  @override
  JournalEntry read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return JournalEntry.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer.writeMap(obj.toMap());
  }
}
