import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Models/mood.dart';
import '../Services/ads_service.dart';
import '../Widgets/state_widgets.dart';
import '../providers/app_state_provider.dart';
import '../providers/moods_provider.dart';
import '../utils/constants/colors.dart';
import 'journal_screen.dart';
import 'mood_screen.dart';
import 'settings_screen.dart';

class SelfCareScreen extends ConsumerStatefulWidget {
  const SelfCareScreen({super.key});

  @override
  ConsumerState<SelfCareScreen> createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends ConsumerState<SelfCareScreen> {
  static const _gratitudePrompts = [
    'Name three small things you are grateful for today.',
    'Who made you smile recently? Why?',
    'What is a comfort you often overlook?',
    'Describe a moment of calm you felt this week.',
    'What is something your body did for you today?',
    'What is a tiny win you can celebrate right now?',
  ];

  static const _selfCareIdeas = [
    'Take a 5-minute screen break and stretch.',
    'Drink a full glass of water.',
    'Step outside for fresh air.',
    'Listen to a song you love.',
    'Text someone you appreciate.',
    'Tidy one small surface in your space.',
    'Do a 1-minute body scan.',
    'Light a candle and read for 10 minutes.',
  ];

  void _showGratitudePrompt() {
    final prompt =
        _gratitudePrompts[Random().nextInt(_gratitudePrompts.length)];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Gratitude prompt'),
        content: Text(prompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSelfCareIdeas() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Self-care ideas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              for (final idea in _selfCareIdeas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(idea)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBreathing() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _BreathingScreen()),
    );
  }

  Future<void> _unlockPremiumTheme() async {
    final messenger = ScaffoldMessenger.of(context);
    final shown = await AdsService.instance.showRewarded(() {
      ref.read(premiumThemeProvider.notifier).unlock();
    });
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(shown
            ? 'Premium theme unlocked!'
            : 'Reward ad unavailable — try again later.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moods = ref.watch(moodsProvider);
    final today = ref.read(moodsProvider.notifier).todayMood();
    final premium = ref.watch(premiumThemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(moodsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _MoodTodayCard(
              mood: today,
              onCheckIn: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MoodCheckInScreen()),
              ),
            ),
            const SizedBox(height: 16),
            const _SectionTitle('Quick actions'),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _ActionTile(
                  icon: Icons.air_rounded,
                  label: 'Breathing',
                  color: AppColors.info,
                  onTap: _openBreathing,
                ),
                _ActionTile(
                  icon: Icons.menu_book_rounded,
                  label: 'Journal',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JournalScreen()),
                  ),
                ),
                _ActionTile(
                  icon: Icons.emoji_emotions_rounded,
                  label: 'Gratitude',
                  color: AppColors.warning,
                  onTap: _showGratitudePrompt,
                ),
                _ActionTile(
                  icon: Icons.spa_rounded,
                  label: 'Ideas',
                  color: AppColors.success,
                  onTap: _showSelfCareIdeas,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Mood history (last 7 days)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: SizedBox(
                height: 180,
                child: moods.isEmpty
                    ? const EmptyState(
                        icon: Icons.bar_chart_rounded,
                        title: 'No mood data yet',
                        message: 'Check in to start tracking how you feel.',
                      )
                    : _MoodChart(moods: moods),
              ),
            ),
            const SizedBox(height: 20),
            _PremiumThemeCard(unlocked: premium, onUnlock: _unlockPremiumTheme),
            const SizedBox(height: 16),
            const _TipsCard(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MoodTodayCard extends StatelessWidget {
  final Mood? mood;
  final VoidCallback onCheckIn;
  const _MoodTodayCard({required this.mood, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.pinkGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood == null
                      ? 'How are you feeling today?'
                      : 'Today you feel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  mood == null ? 'Check in' : '${mood!.emoji}  ${mood!.label}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (mood != null && mood!.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: mood!.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                t,
                                style:
                                    const TextStyle(color: Colors.white),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
            ),
            child: Text(mood == null ? 'Check in' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  final List<Mood> moods;
  const _MoodChart({required this.moods});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final buckets = List<double>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (final m in moods) {
      final diff = now
          .difference(DateTime(m.date.year, m.date.month, m.date.day))
          .inDays;
      if (diff >= 0 && diff < 7) {
        final idx = 6 - diff;
        buckets[idx] += m.rating.toDouble();
        counts[idx] += 1;
      }
    }
    final values = List<double>.generate(
        7, (i) => counts[i] == 0 ? 0 : buckets[i] / counts[i]);

    return BarChart(
      BarChartData(
        maxY: 5,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                final day = now.subtract(Duration(days: 6 - idx));
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[(day.weekday - 1) % 7],
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < 7; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i],
                width: 16,
                color: AppColors.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ]),
        ],
      ),
    );
  }
}

class _PremiumThemeCard extends StatelessWidget {
  final bool unlocked;
  final VoidCallback onUnlock;
  const _PremiumThemeCard({required this.unlocked, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlocked ? 'Premium theme unlocked' : 'Premium theme',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  unlocked
                      ? 'Enjoy your unlocked perks.'
                      : 'Watch a short ad to unlock.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (!unlocked)
            TextButton(onPressed: onUnlock, child: const Text('Unlock')),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined,
              color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Small daily check-ins add up. Be patient with yourself.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingScreen extends StatefulWidget {
  const _BreathingScreen();

  @override
  State<_BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<_BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _phaseTimer;
  int _phase = 0;

  static const _phaseLabels = ['Inhale', 'Hold', 'Exhale'];
  static const _phaseDurations = [
    Duration(seconds: 4),
    Duration(seconds: 2),
    Duration(seconds: 6),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _phaseDurations[0],
      lowerBound: 0.4,
      upperBound: 1.0,
    );
    _runPhase();
  }

  void _runPhase() {
    if (!mounted) return;
    _controller.duration = _phaseDurations[_phase];
    if (_phase == 0) {
      _controller.forward(from: 0.4);
    } else if (_phase == 2) {
      _controller.reverse(from: 1.0);
    } else {
      _controller.value = 1.0;
    }
    _phaseTimer = Timer(_phaseDurations[_phase], () {
      if (!mounted) return;
      setState(() => _phase = (_phase + 1) % 3);
      _runPhase();
    });
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final scale = _controller.value;
                return Container(
                  width: 220 * scale,
                  height: 220 * scale,
                  decoration: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 36),
            Text(
              _phaseLabels[_phase],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Follow the rhythm. Soft inhale, gentle exhale.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
