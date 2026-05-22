import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:selfcare/Models/task.dart';
import 'package:selfcare/Screens/add_task_screen.dart';
import 'package:selfcare/Screens/journal_screen.dart';
import 'package:selfcare/Screens/mood_screen.dart';
import 'package:selfcare/Services/ads_service.dart';
import 'package:selfcare/Widgets/ad_widgets.dart';
import 'package:selfcare/Widgets/bottomnavbar.dart';
import 'package:selfcare/Widgets/state_widgets.dart';
import 'package:selfcare/providers/moods_provider.dart';
import 'package:selfcare/providers/study_provider.dart';
import 'package:selfcare/providers/tasks_provider.dart';
import 'package:selfcare/utils/constants/colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  Future<void> _switchTab(BuildContext context, int index) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => BottomNavScreen(index: index)),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(tasksProvider);
    ref.invalidate(moodsProvider);
    ref.invalidate(studyProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final tasksNotifier = ref.read(tasksProvider.notifier);
    ref.watch(tasksProvider);
    final todayTasks = tasksNotifier.todayTasks()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.dueDateTime.compareTo(b.dueDateTime);
      });
    final completed = tasksNotifier.completedToday();
    final totalToday = todayTasks.length;

    final moodsNotifier = ref.read(moodsProvider.notifier);
    ref.watch(moodsProvider);
    final todayMood = moodsNotifier.todayMood();

    final studyNotifier = ref.read(studyProvider.notifier);
    final studyState = ref.watch(studyProvider);
    final minutesWeek = studyNotifier.minutesThisWeek();
    final streak = studyState.achievement.streak;

    final visibleTasks = todayTasks.take(5).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                children: [
                  _Header(
                    greeting: _greeting(now),
                    dateLabel: DateFormat('EEEE, MMM d').format(now),
                  ),
                  const SizedBox(height: 20),
                  _MoodCard(
                    mood: todayMood?.emoji,
                    label: todayMood?.label,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MoodCheckInScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _QuickStatsRow(
                    tasksToday: '$completed / $totalToday',
                    focusWeek: _formatMinutes(minutesWeek),
                    streak: '$streak',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Tasks",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () => _switchTab(context, 1),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (visibleTasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: EmptyState(
                        icon: Icons.checklist_rounded,
                        title: 'Nothing planned',
                        message:
                            'Tap the button below to add your first task for today.',
                        actionLabel: 'Add task',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTaskScreen(),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    ...visibleTasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HomeTaskTile(
                          task: t,
                          onToggle: () async {
                            final updated =
                                await tasksNotifier.toggleComplete(t);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: updated.isCompleted
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  content: Text(
                                    updated.isCompleted
                                        ? 'Nice work! Task completed.'
                                        : 'Task marked as active.',
                                  ),
                                ),
                              );
                            if (updated.isCompleted) {
                              AdsService.instance.maybeShowInterstitial();
                            }
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  Text(
                    'Quick actions',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.add_task_rounded,
                          label: 'Add task',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTaskScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.book_outlined,
                          label: 'Journal',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const JournalScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.menu_book_rounded,
                          label: 'Study',
                          onTap: () => _switchTab(context, 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Center(child: BannerAdWidget()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String dateLabel;

  const _Header({required this.greeting, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.favorite, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String? mood;
  final String? label;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMood = mood != null && label != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  hasMood ? mood! : '🌸',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasMood ? "Today's mood" : 'How are you feeling?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasMood
                          ? label!
                          : 'Take a moment for a quick mood check-in.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final String tasksToday;
  final String focusWeek;
  final String streak;

  const _QuickStatsRow({
    required this.tasksToday,
    required this.focusWeek,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            label: 'Tasks today',
            value: tasksToday,
            accent: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: 'Focus / week',
            value: focusWeek,
            accent: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '🔥 $streak',
            accent: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _HomeTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const _HomeTaskTile({required this.task, required this.onToggle});

  Color _priorityColor() {
    switch (task.priority) {
      case 'High':
        return AppColors.accent;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primary
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.formattedTime,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.category,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
