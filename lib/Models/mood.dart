import 'package:hive/hive.dart';

class Mood {
  final String id;
  final DateTime date;
  final int rating; // 1..5
  final List<String> tags;
  final String? note;

  Mood({
    required this.id,
    required this.date,
    required this.rating,
    this.tags = const [],
    this.note,
  });

  String get emoji {
    switch (rating) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  String get label {
    switch (rating) {
      case 1:
        return 'Awful';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return 'Okay';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'rating': rating,
        'tags': tags,
        'note': note,
      };

  factory Mood.fromMap(Map<dynamic, dynamic> map) => Mood(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        rating: (map['rating'] as num).toInt(),
        tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        note: map['note'] as String?,
      );
}

class MoodAdapter extends TypeAdapter<Mood> {
  @override
  final int typeId = 2;

  @override
  Mood read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return Mood.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Mood obj) {
    writer.writeMap(obj.toMap());
  }
}
