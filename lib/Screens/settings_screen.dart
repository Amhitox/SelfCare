import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Services/ads_service.dart';
import '../Services/notification_service.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants/colors.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _info;
  bool _loadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _info = info;
        _loadingInfo = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingInfo = false);
    }
  }

  Future<void> _requestNotifications() async {
    await NotificationService.requestPermissions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification permissions requested.')),
    );
  }

  Future<void> _unlockPremiumTheme() async {
    final messenger = ScaffoldMessenger.of(context);
    final shown = await AdsService.instance.showRewarded(
      () => ref.read(premiumThemeProvider.notifier).unlock(),
    );
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(shown
          ? 'Premium theme unlocked!'
          : 'Reward ad unavailable — try again later.'),
    ));
  }

  Future<void> _unlockExtraStats() async {
    final messenger = ScaffoldMessenger.of(context);
    final shown = await AdsService.instance.showRewarded(
      () => ref.read(extraStatsProvider.notifier).unlock(),
    );
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(shown
          ? 'Extra stats unlocked!'
          : 'Reward ad unavailable — try again later.'),
    ));
  }

  Future<void> _openPrivacy() async {
    final uri = Uri.parse('https://selfcare.app/privacy');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open privacy policy.')),
      );
    }
  }

  Future<void> _replayOnboarding() async {
    await ref.read(onboardingProvider.notifier).reset();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final premium = ref.watch(premiumThemeProvider);
    final extra = ref.watch(extraStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionLabel('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Use a darker palette to reduce eye strain.'),
            value: theme == ThemeMode.dark,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => ref
                .read(themeProvider.notifier)
                .setTheme(v ? ThemeMode.dark : ThemeMode.light),
          ),
          const Divider(height: 1),
          _SectionLabel('Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Allow reminders'),
            subtitle: const Text('Request notification permissions.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _requestNotifications,
          ),
          const Divider(height: 1),
          _SectionLabel('Unlocks'),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined,
                color: AppColors.warning),
            title: const Text('Premium theme'),
            subtitle: Text(premium ? 'Unlocked' : 'Watch a short ad to unlock'),
            trailing: premium
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : TextButton(
                    onPressed: _unlockPremiumTheme,
                    child: const Text('Unlock'),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined,
                color: AppColors.info),
            title: const Text('Extra stats view'),
            subtitle: Text(extra ? 'Unlocked' : 'Watch a short ad to unlock'),
            trailing: extra
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : TextButton(
                    onPressed: _unlockExtraStats,
                    child: const Text('Unlock'),
                  ),
          ),
          const Divider(height: 1),
          _SectionLabel('General'),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Replay onboarding'),
            onTap: _replayOnboarding,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: _openPrivacy,
          ),
          const Divider(height: 1),
          _SectionLabel('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: _loadingInfo
                ? const Text('Loading…')
                : Text(_info == null
                    ? 'Unknown'
                    : '${_info!.version} (${_info!.buildNumber})'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Made with care.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
      ),
    );
  }
}
