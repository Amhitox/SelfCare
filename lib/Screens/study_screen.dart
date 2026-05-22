import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:selfcare/Models/study_session.dart';
import 'package:selfcare/Services/ads_service.dart';
import 'package:selfcare/Services/notification_service.dart';
import 'package:selfcare/Widgets/state_widgets.dart';
import 'package:selfcare/providers/study_provider.dart';
import 'package:selfcare/utils/constants/colors.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  static const List<int> _durations = [15, 25, 45, 60];

  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setDuration(int minutes) {
    if (_running) return;
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _running = false;
        });
        _onCompleted();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  Future<void> _onCompleted() async {
    final minutes = _selectedMinutes;
    await ref.read(studyProvider.notifier).addSession(minutes);
    if (!mounted) return;
    final achievement = ref.read(studyProvider).achievement;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Session complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Great focus for $minutes minutes.'),
            const SizedBox(height: 8),
            Text('Streak: ${achievement.streak} day(s)'),
            Text('Total focus: ${achievement.totalFocusTime}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Nice'),
          ),
        ],
      ),
    );
    unawaited(AdsService.instance.maybeShowInterstitial());
    unawaited(NotificationService.showNow(
      'Session complete!',
      'Great focus - keep it going.',
    ));
    setState(() => _remainingSeconds = _selectedMinutes * 60);
  }

  String _formatMmSs(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _confirmDelete(StudySession session) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete session?'),
        content: const Text('This will remove the session permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(studyProvider.notifier).deleteSession(session);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final study = ref.watch(studyProvider);
    final achievement = study.achievement;
    final weekMinutes = ref.read(studyProvider.notifier).minutesThisWeek();
    final totalSeconds = _selectedMinutes * 60;
    final progress =
        totalSeconds == 0 ? 0.0 : 1 - (_remainingSeconds / totalSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsRow(
                streak: achievement.streak,
                sessions: achievement.sessions,
                totalFocus: achievement.totalFocusTime,
                weekMinutes: weekMinutes,
              ),
              const SizedBox(height: 20),
              _DurationPicker(
                durations: _durations,
                selected: _selectedMinutes,
                onSelected: _setDuration,
                disabled: _running,
              ),
              const SizedBox(height: 20),
              Center(
                child: CircularPercentIndicator(
                  radius: 120,
                  lineWidth: 14,
                  percent: progress.clamp(0.0, 1.0),
                  animation: false,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  progressColor: AppColors.primary,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMmSs(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _running ? 'Focusing' : 'Ready',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _running ? _pause : _start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(_running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(_running ? 'Pause' : 'Start'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Recent sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _RecentSessions(
                sessions: study.sessions.take(5).toList(),
                onDelete: _confirmDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int streak;
  final int sessions;
  final String totalFocus;
  final int weekMinutes;

  const _StatsRow({
    required this.streak,
    required this.sessions,
    required this.totalFocus,
    required this.weekMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '$streak',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.timer_outlined,
            label: 'Sessions',
            value: '$sessions',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.bolt_rounded,
            label: 'Focus',
            value: totalFocus,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_view_week_rounded,
            label: 'Week',
            value: '${weekMinutes}m',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final List<int> durations;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool disabled;

  const _DurationPicker({
    required this.durations,
    required this.selected,
    required this.onSelected,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: durations.map((m) {
        final isSelected = m == selected;
        return FilterChip(
          label: Text('$m min'),
          selected: isSelected,
          onSelected: disabled ? null : (_) => onSelected(m),
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentSessions extends StatelessWidget {
  final List<StudySession> sessions;
  final Future<void> Function(StudySession) onDelete;

  const _RecentSessions({required this.sessions, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: EmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No sessions yet',
          message: 'Start your first focus session above.',
        ),
      );
    }
    final fmt = DateFormat('EEE, MMM d - h:mm a');
    return Column(
      children: sessions
          .map(
            (s) => Dismissible(
              key: ValueKey(s.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                await onDelete(s);
                return false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.delete_outline, color: AppColors.error),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fmt.format(s.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${s.durationMinutes}m',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
