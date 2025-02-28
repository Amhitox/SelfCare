import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selfcare/Services/alarm_service.dart';
import 'package:selfcare/Widgets/bottomnavbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> features = [
    {
      'title': 'Tasks Tracker',
      'subtitle': 'What you planned to do today?',
      'icon': '✨',
      'color': Color(0xFF98BDFF),
    },
    {
      'title': 'Study Timer',
      'subtitle': 'Focus on your goals',
      'icon': '📚',
      'color': Color(0xFF4ECDC4),
    },
    {
      'title': 'Self Care',
      'subtitle': 'Take care of yourself',
      'icon': '🌸',
      'color': Color(0xFFFF9999),
    },
  ];

  final categories = [
    {
      'name': 'Today',
      'icon': Icons.today,
      'color': Color(0xFF6C63FF),
      'count': 5,
    },
    {
      'name': 'Self-Care',
      'icon': Icons.favorite,
      'color': Color(0xFFFF6B6B),
      'count': 3,
    },
    {
      'name': 'Mindful',
      'icon': Icons.self_improvement,
      'color': Color(0xFF4ECDC4),
      'count': 4,
    },
    {
      'name': 'Exercise',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFFBE0B),
      'count': 2,
    },
  ];

  final quotes = [
    'The only way to do great work is to love what you do.',
    'Believe you can and you\'re halfway there.',
    'The future belongs to those who believe in the beauty of their dreams.',
    'It’s not about ideas. It’s about making ideas happen.',
    'Success is not the key to happiness. Happiness is the key to success.',
    'Do what you can, with what you have, where you are.',
    'Opportunities don’t happen, you create them.',
    'Your time is limited, so don’t waste it living someone else’s life.',
    'Why do programmers prefer dark mode? Because light attracts bugs!',
    'There are 10 types of people in the world: those who understand binary and those who don’t.',
    'Why did the programmer quit his job? Because he didn’t get arrays!',
    'I told my computer I needed a break, and now it won’t stop sending me vacation ads.',
    'Why do Java developers wear glasses? Because they don’t C#!',
    'A SQL query walks into a bar, walks up to two tables, and asks: "Can I join you?"',
    'Why was the function so calm? Because it had a lot of parameters under control.',
    'Debugging is like being the detective in a crime movie where you are also the murderer.',
  ];

  Color getColorByTitle(String title) {
    return categories.firstWhere(
      (category) => category['name'] == title,
      orElse: () => categories[0],
    )['color'] as Color;
  }

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    print(tasks);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = prefs.getString('tasks') ?? '[]';
    final List<dynamic> tasksData = jsonDecode(tasksJson);

    setState(() {
      tasks = tasksData.map((json) => Task.fromMap(json)).toList();
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
    await AlarmService.scheduleTaskAlarm(updatedTask);

    setState(() {
      tasks = currentTasks;
    });
  }

  final List<Map<String, dynamic>> insights = [
    {
      'title': 'Mood Streak',
      'value': '7 days',
      'icon': Icons.favorite,
      'color': Color(0xFFFF9999),
    },
    {
      'title': 'Study Time',
      'value': '2.5 hrs',
      'icon': Icons.timer,
      'color': Color(0xFF4ECDC4),
    },
    {
      'title': 'Tasks Done',
      'value': '85%',
      'icon': Icons.task_alt,
      'color': Color(0xFF98BDFF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildQuoteCard(),
              _buildFeatureGrid(),
              if (tasks.isNotEmpty) _buildDailyTasks(),
            ],
          ),
        ),
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
                    'Good ${_getGreeting()}! ✨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dhsiis',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return GestureDetector(
          onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavScreen(
                        index: index,
                      ))),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: feature['color'].withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  feature['icon'],
                  style: TextStyle(fontSize: 40),
                ),
                SizedBox(height: 10),
                Text(
                  feature['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  feature['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyTasks() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          ...tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getColorByTitle(task.category).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (task.isCompleted) {
                    task.isCompleted = task.isCompleted;
                  } else {
                    task.isCompleted = !task.isCompleted;
                  }
                  _editTask(task);
                });
              },
              child: Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: getColorByTitle(task.category),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  task.formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: getColorByTitle(task.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              task.category,
              style: TextStyle(
                fontSize: 12,
                color: getColorByTitle(task.category),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      margin: EdgeInsets.all(20),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF98BDFF), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            '"${quotes[Random().nextInt(quotes.length)]}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            '- Dhsis Quote',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
