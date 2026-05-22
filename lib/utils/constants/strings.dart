class AppStrings {
  AppStrings._();

  static const String appName = 'SelfCare';
  static const String tagline = 'Your daily wellness companion';

  // Onboarding
  static const String onboardTitle1 = 'Plan your day';
  static const String onboardDesc1 =
      'Organize tasks, set reminders and stay on top of what matters.';
  static const String onboardTitle2 = 'Focus & study';
  static const String onboardDesc2 =
      'Pomodoro timer, sessions log and a streak that rewards consistency.';
  static const String onboardTitle3 = 'Mind your mood';
  static const String onboardDesc3 =
      'Daily check-ins, journaling and gentle nudges toward self-care.';
}

class AppConsts {
  AppConsts._();

  static const String hiveTasksBox = 'tasks_box';
  static const String hiveMoodsBox = 'moods_box';
  static const String hiveJournalBox = 'journal_box';
  static const String hiveStudyBox = 'study_box';
  static const String hiveSettingsBox = 'settings_box';

  static const String onboardingKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';
  static const String premiumThemeKey = 'premium_theme_unlocked';
  static const String extraStatsKey = 'extra_stats_unlocked';

  static const List<String> taskCategories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Self-care',
    'Other',
  ];
  static const List<String> taskPriorities = ['Low', 'Medium', 'High'];
}
