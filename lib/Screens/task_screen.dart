import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selfcare/Services/alarm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/task.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int selectedCategoryIndex = 0;

  final categories = [
    {
      'name': 'Today',
      'icon': Icons.today,
      'color': Color(0xFF6C63FF),
    },
    {
      'name': 'Self-Care',
      'icon': Icons.favorite,
      'color': Color(0xFFFF6B6B),
    },
    {
      'name': 'Mindful',
      'icon': Icons.self_improvement,
      'color': Color(0xFF4ECDC4),
    },
    {
      'name': 'Exercise',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFFBE0B),
    },
  ];

  Color getColorByTitle(String title) {
    return categories.firstWhere(
      (category) => category['name'] == title,
      orElse: () => categories[0],
    )['color'] as Color;
  }

  List<Task> tasks = [];
  List<Task> filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = prefs.getString('tasks') ?? '[]';
    final List<dynamic> tasksData = jsonDecode(tasksJson);
    setState(() {
      tasks = tasksData.map((json) => Task.fromMap(json)).toList();
      filteredTasks = tasks.where((task) => !task.isCompleted).toList();
    });
  }

  Future<void> _editTask(Task updatedTask) async {
    final prefs = await SharedPreferences.getInstance();

    final String tasksJson = prefs.getString('tasks') ?? '[]';
    List<dynamic> tasksList = jsonDecode(tasksJson);
    List<Task> currentTasks = tasksList.map((t) => Task.fromMap(t)).toList();

    final existingIndex =
        currentTasks.indexWhere((t) => t.id == updatedTask.id);
    if (existingIndex != -1) {
      currentTasks[existingIndex] = updatedTask;
    }

    final String updatedTasksJson =
        jsonEncode(currentTasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', updatedTasksJson);

    await AlarmService.cancelTaskAlarm(updatedTask);

    setState(() {
      tasks = currentTasks;
      filteredTasks = tasks.where((task) => !task.isCompleted).toList();
    });
  }

  Future<void> _deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();

    final String tasksJson = prefs.getString('tasks') ?? '[]';
    List<dynamic> tasksList = jsonDecode(tasksJson);
    List<Task> currentTasks = tasksList.map((t) => Task.fromMap(t)).toList();

    final taskToCancel = currentTasks.firstWhere((t) => t.id == taskId);

    currentTasks.removeWhere((t) => t.id == taskId);

    final String updatedTasksJson =
        jsonEncode(currentTasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', updatedTasksJson);

    await AlarmService.cancelTaskAlarm(taskToCancel);

    setState(() {
      tasks = currentTasks;
      filteredTasks = tasks.where((task) => !task.isCompleted).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategories(),
            _buildTasksList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        backgroundColor: categories[selectedCategoryIndex]['color'] as Color,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        tooltip: 'Add new task',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 6),
                            Text(
                              DateFormat('MMM d, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () => setState(() {
              selectedCategoryIndex = index;
              if (index != 0) {
                filteredTasks = tasks
                    .where((task) =>
                        task.category == category['name'] && !task.isCompleted)
                    .toList();
              } else {
                filteredTasks =
                    tasks.where((task) => !task.isCompleted).toList();
              }
            }),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 15, top: 10, bottom: 10),
              width: 130,
              decoration: BoxDecoration(
                color: isSelected ? category['color'] as Color : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? (category['color'] as Color).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : (category['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: isSelected
                          ? Colors.white
                          : category['color'] as Color,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    category['name'] != 'Today'
                        ? '${tasks.where((task) => task.category == category['name'] && !task.isCompleted).length} tasks'
                        : '${tasks.where((task) => !task.isCompleted).length} tasks',
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: getColorByTitle(task.category).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Dismissible(
          key: Key(task.title),
          background: _buildDismissBackground(true),
          secondaryBackground: _buildDismissBackground(false),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              task.isCompleted = true;
              _editTask(task);
            } else if (direction == DismissDirection.endToStart) {
              _deleteTask(task.id);
            }
          },
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                task.description ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildPriorityBadge(task.priority),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: getColorByTitle(task.category),
                        ),
                        SizedBox(width: 8),
                        Text(
                          task.formattedTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDismissBackground(bool isComplete) {
    return Container(
      color: isComplete ? Colors.green : Colors.red,
      alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isComplete ? Icons.check_circle : Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Color(0xFFFF6B6B);
      case 'medium':
        return Color(0xFFFFBE0B);
      case 'low':
        return Color(0xFF4ECDC4);
      default:
        return Colors.grey;
    }
  }
}
