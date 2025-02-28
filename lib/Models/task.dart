import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final TimeOfDay dueTime;
  final String category;
  final String priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.dueTime,
    required this.category,
    required this.priority,
    this.isCompleted = false,
  });

  // Convert Task to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueTime': {'hour': dueTime.hour, 'minute': dueTime.minute},
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  // Create Task from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      dueTime: TimeOfDay(
        hour: map['dueTime']['hour'],
        minute: map['dueTime']['minute'],
      ),
      category: map['category'],
      priority: map['priority'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Create a copy of the task with some fields updated
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    TimeOfDay? dueTime,
    String? category,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueTime: dueTime ?? this.dueTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Add these getter methods
  String get formattedTime =>
      '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}';
}
