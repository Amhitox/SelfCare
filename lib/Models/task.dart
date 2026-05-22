import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Task {
  final String id;
  String title;
  String? description;
  DateTime createdAt;
  DateTime dueDate;
  TimeOfDay dueTime;
  String category;
  String priority;
  bool isCompleted;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.dueDate,
    required this.dueTime,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    this.completedAt,
  });

  String get formattedTime =>
      '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}';

  DateTime get dueDateTime => DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime.hour,
        dueTime.minute,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'dueTime': {'hour': dueTime.hour, 'minute': dueTime.minute},
        'category': category,
        'priority': priority,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Task.fromMap(Map<dynamic, dynamic> map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        dueDate: map['dueDate'] != null
            ? DateTime.parse(map['dueDate'] as String)
            : DateTime.parse(map['createdAt'] as String),
        dueTime: TimeOfDay(
          hour: (map['dueTime']['hour'] as num).toInt(),
          minute: (map['dueTime']['minute'] as num).toInt(),
        ),
        category: map['category'] as String,
        priority: map['priority'] as String,
        isCompleted: map['isCompleted'] as bool? ?? false,
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : null,
      );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    String? category,
    String? priority,
    bool? isCompleted,
    DateTime? completedAt,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate ?? this.dueDate,
        dueTime: dueTime ?? this.dueTime,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
      );
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return Task.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeMap(obj.toMap());
  }
}
