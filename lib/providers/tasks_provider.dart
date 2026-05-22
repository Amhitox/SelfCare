import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../Models/task.dart';
import '../Services/storage_service.dart';
import '../Services/notification_service.dart';

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]) {
    _load();
  }

  static const _uuid = Uuid();

  void _load() {
    state = StorageService.tasksBox.values.toList()
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
  }

  Future<Task> add({
    required String title,
    String? description,
    required DateTime dueDate,
    required TimeOfDay dueTime,
    required String category,
    required String priority,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      dueTime: dueTime,
      category: category,
      priority: priority,
    );
    await StorageService.tasksBox.put(task.id, task);
    await NotificationService.scheduleTaskReminder(task);
    _load();
    return task;
  }

  Future<void> update(Task task) async {
    await StorageService.tasksBox.put(task.id, task);
    await NotificationService.cancelTaskReminder(task);
    if (!task.isCompleted) {
      await NotificationService.scheduleTaskReminder(task);
    }
    _load();
  }

  Future<void> delete(Task task) async {
    await NotificationService.cancelTaskReminder(task);
    await StorageService.tasksBox.delete(task.id);
    _load();
  }

  Future<Task> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await StorageService.tasksBox.put(updated.id, updated);
    if (updated.isCompleted) {
      await NotificationService.cancelTaskReminder(updated);
    } else {
      await NotificationService.scheduleTaskReminder(updated);
    }
    _load();
    return updated;
  }

  List<Task> todayTasks() {
    final now = DateTime.now();
    return state
        .where((t) =>
            t.dueDate.year == now.year &&
            t.dueDate.month == now.month &&
            t.dueDate.day == now.day)
        .toList();
  }

  int completedToday() => todayTasks().where((t) => t.isCompleted).length;
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<Task>>((ref) => TasksNotifier());
