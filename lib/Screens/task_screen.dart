import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

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

  final tasks = [
    {
      'title': 'Morning Meditation',
      'description': 'Start your day with mindfulness',
      'time': '08:00 AM',
      'duration': '15 min',
      'category': 'Mindful',
      'priority': 'High',
      'isCompleted': false,
      'color': Color(0xFF4ECDC4),
    },
    {
      'title': 'Yoga Session',
      'description': 'Gentle flow and stretching',
      'time': '09:30 AM',
      'duration': '30 min',
      'category': 'Exercise',
      'priority': 'Medium',
      'isCompleted': false,
      'color': Color(0xFFFFBE0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFC),
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
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: categories[selectedCategoryIndex]['color'] as Color,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        tooltip: 'Add new task',
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
    return Container(
      height: 140,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedCategoryIndex = index),
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
                    '${category['count']} tasks',
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
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (task['color'] as Color).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Dismissible(
          key: Key(task['title']),
          background: _buildDismissBackground(true),
          secondaryBackground: _buildDismissBackground(false),
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
                                task['title'] as String? ?? 'Untitled Task',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                task['description'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildPriorityBadge(task['priority'] as String),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: task['color'] as Color,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${task['time']} • ${task['duration']}',
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
