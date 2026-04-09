import 'package:hive/hive.dart';

import '../../../core/utils/logger.dart';

/// User preferences data source using Hive key-value storage
class UserPreferencesDataSource {
  static const _boxName = 'preferences';

  // Preference keys
  static const String keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLanguage = 'language';
  static const String keySemanticSearchEnabled = 'semantic_search_enabled';
  static const String keyLastFeedFetchTime = 'last_feed_fetch_time';
  static const String keyTagPreferences = 'tag_preferences'; // JSON map
  static const String keyReadStats = 'read_stats'; // JSON map
  static const String keyOnboardingCompleted = 'onboarding_completed';

  Box? _box;

  /// Get or open the Hive box
  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  // ─── Theme ───

  Future<String> getThemeMode() async {
    final box = await _getBox();
    return box.get(keyThemeMode, defaultValue: 'system') as String;
  }

  Future<void> setThemeMode(String mode) async {
    final box = await _getBox();
    await box.put(keyThemeMode, mode);
  }

  // ─── Notifications ───

  Future<bool> isNotificationsEnabled() async {
    final box = await _getBox();
    return box.get(keyNotificationsEnabled, defaultValue: true) as bool;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final box = await _getBox();
    await box.put(keyNotificationsEnabled, enabled);
  }

  // ─── Language ───

  Future<String> getLanguage() async {
    final box = await _getBox();
    return box.get(keyLanguage, defaultValue: 'zh_CN') as String;
  }

  Future<void> setLanguage(String language) async {
    final box = await _getBox();
    await box.put(keyLanguage, language);
  }

  // ─── Semantic Search ───

  Future<bool> isSemanticSearchEnabled() async {
    final box = await _getBox();
    return box.get(keySemanticSearchEnabled, defaultValue: false) as bool;
  }

  Future<void> setSemanticSearchEnabled(bool enabled) async {
    final box = await _getBox();
    await box.put(keySemanticSearchEnabled, enabled);
  }

  // ─── Tag Preferences (for weight algorithm) ───

  Future<Map<String, double>> getTagPreferences() async {
    final box = await _getBox();
    final raw = box.get(keyTagPreferences);
    if (raw == null) return {};
    try {
      final map = Map<String, dynamic>.from(raw as Map);
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      logger.e('Failed to parse tag preferences', error: e);
      return {};
    }
  }

  Future<void> setTagPreferences(Map<String, double> preferences) async {
    final box = await _getBox();
    await box.put(keyTagPreferences, preferences);
  }

  /// Update tag preference based on user action
  Future<void> updateTagPreference(
    List<String> tags, {
    required bool isLiked,
    required bool isDisliked,
  }) async {
    final prefs = await getTagPreferences();
    for (final tag in tags) {
      final current = prefs[tag] ?? 1.0;
      if (isLiked) {
        prefs[tag] = current * 1.2;
      } else if (isDisliked) {
        prefs[tag] = current * 0.8;
      }
    }
    await setTagPreferences(prefs);
  }

  // ─── Read Stats ───

  Future<Map<String, dynamic>> getReadStats() async {
    final box = await _getBox();
    final raw = box.get(keyReadStats);
    if (raw == null) return {'totalRead': 0, 'totalVerified': 0};
    try {
      return Map<String, dynamic>.from(raw as Map);
    } catch (e) {
      logger.e('Failed to parse read stats', error: e);
      return {'totalRead': 0, 'totalVerified': 0};
    }
  }

  Future<void> setReadStats(Map<String, dynamic> stats) async {
    final box = await _getBox();
    await box.put(keyReadStats, stats);
  }

  /// Increment read count
  Future<void> incrementReadCount() async {
    final stats = await getReadStats();
    stats['totalRead'] = ((stats['totalRead'] ?? 0) as num).toInt() + 1;
    await setReadStats(stats);
  }

  /// Increment verified count
  Future<void> incrementVerifiedCount() async {
    final stats = await getReadStats();
    stats['totalVerified'] = ((stats['totalVerified'] ?? 0) as num).toInt() + 1;
    await setReadStats(stats);
  }

  // ─── Onboarding ───

  Future<bool> isOnboardingCompleted() async {
    final box = await _getBox();
    return box.get(keyOnboardingCompleted, defaultValue: false) as bool;
  }

  Future<void> setOnboardingCompleted() async {
    final box = await _getBox();
    await box.put(keyOnboardingCompleted, true);
  }

  // ─── Last Feed Fetch ───

  Future<DateTime?> getLastFeedFetchTime() async {
    final box = await _getBox();
    final ms = box.get(keyLastFeedFetchTime) as int?;
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastFeedFetchTime(DateTime time) async {
    final box = await _getBox();
    await box.put(keyLastFeedFetchTime, time.millisecondsSinceEpoch);
  }

  // ─── Cleanup ───

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
