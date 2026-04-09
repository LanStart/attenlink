/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'AttenLink';
  static const String appTagline = '专注事实的AI资讯聚合';

  // Hive box names
  static const String settingsBox = 'settings';
  static const String preferencesBox = 'preferences';
  static const String feedCacheBox = 'feed_cache';

  // Default feed sources
  static const List<Map<String, String>> defaultFeeds = [
    {'name': 'Hacker News', 'url': 'https://hnrss.org/frontpage', 'type': 'rss'},
    {'name': 'TechCrunch', 'url': 'https://techcrunch.com/feed/', 'type': 'rss'},
    {'name': 'The Verge', 'url': 'https://www.theverge.com/rss/index.xml', 'type': 'rss'},
  ];

  // AI Provider IDs
  static const String openai = 'openai';
  static const String claude = 'claude';
  static const String gemini = 'gemini';
  static const String kimi = 'kimi';
  static const String glm = 'glm';

  // Verification verdicts
  static const String verified = 'verified';
  static const String disputed = 'disputed';
  static const String unverified = 'unverified';
  static const String outdated = 'outdated';

  // Animation durations
  static const Duration cardSwipeDuration = Duration(milliseconds: 300);
  static const Duration cardAnimationDuration = Duration(milliseconds: 400);
  static const Duration verificationPulseDuration = Duration(milliseconds: 1500);

  // Swipe thresholds
  static const double swipeThreshold = 0.35;

  // Pagination
  static const int defaultPageSize = 20;

  // Background task IDs
  static const String feedFetchTaskId = 'feed_fetch';
  static const String verificationTaskId = 'verification_followup';
}
