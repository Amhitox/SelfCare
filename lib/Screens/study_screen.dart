import 'package:flutter/material.dart';
import 'dart:async';
import '../Models/achievement.dart';
import '../Services/achievement_service.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  _StudyScreenState createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with TickerProviderStateMixin {
  bool isTimerRunning = false;
  int selectedMinutes = 25;
  int remainingSeconds = 0;
  int streak = 0;
  int sessions = 0;
  int focusTime = 0;
  Timer? _timer;
  late AnimationController _bounceController;
  Achievement? _achievement;
  bool _isLoading = true;

  final List<int> timerOptions = [25, 30, 45, 60];
  final List<Map<String, dynamic>> studyTips = [
    {
      'tip': 'Take short breaks every 25 minutes',
      'icon': '🌱',
    },
    {
      'tip': 'Stay hydrated while studying',
      'icon': '💧',
    },
    {
      'tip': 'Find a quiet study space',
      'icon': '📚',
    },
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Focus Time',
      'value': '2h 30m',
      'icon': Icons.timer,
      'color': Color(0xFFFFB562),
    },
    {
      'title': 'Sessions',
      'value': '4',
      'icon': Icons.flag,
      'color': Color(0xFF4ECDC4),
    },
    {
      'title': 'Streak',
      'value': '3 days',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFF6B6B),
    },
  ];

  @override
  void initState() {
    super.initState();
    remainingSeconds = selectedMinutes * 60;
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _loadAchievements();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    final achievements = await AchievementService.getAchievements();
    setState(() {
      _achievement = achievements;
      _isLoading = false;
    });
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      isTimerRunning = true;
      remainingSeconds = selectedMinutes * 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          isTimerRunning = false;
        });
        _showCompletionDialog();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
      remainingSeconds = selectedMinutes * 60;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Great job! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You completed your study session!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4ECDC4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildTimer(),
                      SizedBox(height: 30),
                      _buildTimerOptions(),
                      SizedBox(height: 30),
                      _buildAchievements(),
                      SizedBox(height: 30),
                      _buildStudyTips(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Time',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Focus on your goals',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0),
              end: Offset(0, 0.1),
            ).animate(_bounceController),
            child: Text(
              isTimerRunning ? '🎯' : '🌟',
              style: TextStyle(fontSize: 40),
            ),
          ),
          SizedBox(height: 20),
          Text(
            formatTime(remainingSeconds),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerButton(
                isTimerRunning ? 'Pause' : 'Start',
                isTimerRunning ? Icons.pause : Icons.play_arrow,
                isTimerRunning ? pauseTimer : startTimer,
                isTimerRunning ? Color(0xFFFF6B6B) : Color(0xFF4ECDC4),
              ),
              SizedBox(width: 20),
              _buildTimerButton(
                'Reset',
                Icons.refresh,
                resetTimer,
                Colors.grey[400]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildTimerOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: timerOptions.map((minutes) {
        final isSelected = selectedMinutes == minutes;
        return GestureDetector(
          onTap: () {
            if (!isTimerRunning) {
              setState(() {
                selectedMinutes = minutes;
                remainingSeconds = minutes * 60;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF4ECDC4) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? Color(0xFF4ECDC4) : Colors.grey[300]!,
              ),
            ),
            child: Text(
              '$minutes min',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievements() {
    if (_isLoading || _achievement == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAchievementItem(
          Icons.local_fire_department,
          _achievement!.streak.toString(),
          'Streak',
        ),
        _buildAchievementItem(
          Icons.timer,
          _achievement!.sessions.toString(),
          'Sessions',
        ),
        _buildAchievementItem(
          Icons.access_time_filled,
          _achievement!.totalFocusTime,
          'Focus Time',
        ),
      ],
    );
  }

  Widget _buildAchievementItem(
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStudyTips() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Study Tips',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 15),
      ...studyTips.map((tip) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
              Text(
                tip['icon'],
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  tip['tip'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ]);
  }

  // When a study session is completed
  Future<void> _onSessionComplete(int durationMinutes) async {
    if (_achievement != null) {
      final updatedAchievement =
          await AchievementService.addStudySession(durationMinutes);
      setState(() {
        _achievement = updatedAchievement;
      });
    }
  }
}
