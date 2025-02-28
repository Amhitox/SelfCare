import 'package:flutter/material.dart';
import 'package:selfcare/Screens/home_screen.dart';
import 'package:selfcare/Screens/study_screen.dart';

import '../Screens/selfcare_screen.dart';
import '../Screens/task_screen.dart';
import '../utils/constants/colors.dart';

class BottomNavScreen extends StatefulWidget {
  late int index;
  BottomNavScreen({super.key, this.index = -1});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    TasksScreen(),
    StudyScreen(),
    SelfCareScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index + 1;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        backgroundColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedItemColor: AppColors.buttonColor,
        currentIndex: _currentIndex,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.book_sharp), label: 'Study'),
          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined), label: 'Selfcare'),
        ],
      ),
    );
  }
}
