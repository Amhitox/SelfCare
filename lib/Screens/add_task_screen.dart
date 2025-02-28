import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:selfcare/Services/alarm_service.dart';
import 'package:selfcare/Widgets/bottomnavbar.dart';
import 'package:selfcare/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'today';
  String _selectedPriority = 'Medium';

  final List<Map<String, dynamic>> categories = [
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

  final List<String> priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> _saveTasks(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final newTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      dueTime: _selectedTime,
      priority: _selectedPriority,
      category: task.category,
    );

    final String tasksJson = prefs.getString('tasks') ?? '[]';
    List<dynamic> tasksList = jsonDecode(tasksJson);
    List<Task> currentTasks = tasksList.map((t) => Task.fromMap(t)).toList();

    final existingIndex = currentTasks.indexWhere((t) => t.id == newTask.id);
    if (existingIndex != -1) {
      currentTasks[existingIndex] = newTask;
    } else {
      currentTasks.add(newTask);
    }

    final String updatedTasksJson =
        jsonEncode(currentTasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', updatedTasksJson);
    await AlarmService.scheduleTaskAlarm(newTask);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: lightTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create New Task',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: TextStyle(
                color: lightTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'Enter task title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter task description',
                maxLines: 3,
              ),
              SizedBox(height: 20),
              _buildDateTimePicker(),
              SizedBox(height: 20),
              _buildCategorySelector(),
              SizedBox(height: 20),
              _buildPrioritySelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: lightTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: lightTheme.primaryColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: lightTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name'];
                  });
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: isSelected ? category['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: category['color'],
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'],
                        color: isSelected ? Colors.white : category['color'],
                      ),
                      SizedBox(height: 5),
                      Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Row(
          children: priorities.map((priority) {
            final isSelected = _selectedPriority == priority;
            Color priorityColor;
            switch (priority) {
              case 'High':
                priorityColor = Color(0xFFFF6B6B);
                break;
              case 'Medium':
                priorityColor = Color(0xFFFFB562);
                break;
              default:
                priorityColor = Color(0xFF4ECDC4);
            }
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: priority != 'High' ? 15 : 0),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? priorityColor : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: priorityColor,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: isSelected ? Colors.white : priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        dueTime: _selectedTime,
        category: _selectedCategory,
        priority: _selectedPriority,
        isCompleted: false,
      );
      await _saveTasks(task);
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavScreen(
                      index: 0,
                    )));
      }
    }
  }
}
