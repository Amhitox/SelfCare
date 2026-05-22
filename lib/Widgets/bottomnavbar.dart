import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Screens/home_screen.dart';
import '../Screens/task_screen.dart';
import '../Screens/study_screen.dart';
import '../Screens/selfcare_screen.dart';
import '../utils/constants/colors.dart';

class BottomNavScreen extends ConsumerStatefulWidget {
  final int index;
  const BottomNavScreen({super.key, this.index = 0});

  @override
  ConsumerState<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends ConsumerState<BottomNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index.clamp(0, 3);
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    TasksScreen(),
    StudyScreen(),
    SelfCareScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  activeIcon: Icon(Icons.check_circle),
                  label: 'Tasks'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book),
                  label: 'Study'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.self_improvement_outlined),
                  activeIcon: Icon(Icons.self_improvement),
                  label: 'Self-care'),
            ],
          ),
        ),
      ),
    );
  }
}
