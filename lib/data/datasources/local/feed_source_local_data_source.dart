import 'package:hive/hive.dart';

import '../../models/feed_source_config.dart';
import '../../../core/utils/logger.dart';

/// Local data source for feed source configurations using Hive
class FeedSourceLocalDataSource {
  static const _boxName = 'feed_sources';

  Box<String>? _box;

  /// Get or open the Hive box
  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  // ─── CRUD Operations ───

  /// Save a feed source config
  Future<void> saveFeedSource(FeedSourceConfig config) async {
    try {
      final box = await _getBox();
      await box.put(config.id, config.toJsonString());
      logger.d('Saved feed source: ${config.id}');
    } catch (e) {
      logger.e('Failed to save feed source: ${config.id}', error: e);
      rethrow;
    }
  }

  /// Save multiple feed sources
  Future<void> saveFeedSources(List<FeedSourceConfig> configs) async {
    try {
      final box = await _getBox();
      final data = {for (final c in configs) c.id: c.toJsonString()};
      await box.putAll(data);
      logger.d('Saved ${configs.length} feed sources');
    } catch (e) {
      logger.e('Failed to save feed sources batch', error: e);
      rethrow;
    }
  }

  /// Get a single feed source by ID
  Future<FeedSourceConfig?> getFeedSource(String id) async {
    try {
      final box = await _getBox();
      final json = box.get(id);
      if (json == null) return null;
      return FeedSourceConfig.fromJsonString(json);
    } catch (e) {
      logger.e('Failed to get feed source: $id', error: e);
      return null;
    }
  }

  /// Get all feed sources
  Future<List<FeedSourceConfig>> getAllFeedSources() async {
    try {
      final box = await _getBox();
      return box.values
          .map((json) {
            try {
              return FeedSourceConfig.fromJsonString(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<FeedSourceConfig>()
          .toList();
    } catch (e) {
      logger.e('Failed to get all feed sources', error: e);
      return [];
    }
  }

  /// Get enabled feed sources
  Future<List<FeedSourceConfig>> getEnabledFeedSources() async {
    final sources = await getAllFeedSources();
    return sources.where((s) => s.isEnabled).toList();
  }

  /// Get feed sources that need refresh
  Future<List<FeedSourceConfig>> getSourcesNeedingRefresh() async {
    final sources = await getEnabledFeedSources();
    return sources.where((s) => s.needsRefresh).toList();
  }

  /// Delete a feed source
  Future<void> deleteFeedSource(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      logger.d('Deleted feed source: $id');
    } catch (e) {
      logger.e('Failed to delete feed source: $id', error: e);
      rethrow;
    }
  }

  /// Update the last fetched timestamp
  Future<void> updateLastFetched(String id) async {
    final source = await getFeedSource(id);
    if (source == null) return;
    await saveFeedSource(source.copyWith(lastFetchedAt: DateTime.now()));
  }

  /// Toggle feed source enabled/disabled
  Future<void> toggleFeedSource(String id, bool isEnabled) async {
    final source = await getFeedSource(id);
    if (source == null) return;
    await saveFeedSource(source.copyWith(isEnabled: isEnabled));
  }

  /// Get feed source count
  Future<int> getFeedSourceCount() async {
    final box = await _getBox();
    return box.length;
  }

  /// Delete all feed sources
  Future<void> deleteAllFeedSources() async {
    try {
      final box = await _getBox();
      await box.clear();
      logger.d('Cleared all feed sources');
    } catch (e) {
      logger.e('Failed to clear feed sources', error: e);
      rethrow;
    }
  }

  /// Initialize default feed sources if none exist
  Future<void> initializeDefaults() async {
    final existing = await getAllFeedSources();
    if (existing.isNotEmpty) return;

    final defaults = [
      FeedSourceConfig(
        id: 'hn-default',
        name: 'Hacker News',
        url: 'https://hnrss.org/frontpage',
        type: FeedSourceType.hackerNews,
        category: 'tech',
      ),
      FeedSourceConfig(
        id: 'tc-default',
        name: 'TechCrunch',
        url: 'https://techcrunch.com/feed/',
        type: FeedSourceType.rss,
        category: 'tech',
      ),
      FeedSourceConfig(
        id: 'verge-default',
        name: 'The Verge',
        url: 'https://www.theverge.com/rss/index.xml',
        type: FeedSourceType.atom,
        category: 'tech',
      ),
    ];

    await saveFeedSources(defaults);
    logger.d('Initialized ${defaults.length} default feed sources');
  }

  /// Dispose
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
