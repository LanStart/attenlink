import '../datasources/local/feed_source_local_data_source.dart';
import '../models/feed_source_config.dart';

/// Repository for feed source operations
class FeedSourceRepository {
  final FeedSourceLocalDataSource _localDataSource;

  FeedSourceRepository({
    required FeedSourceLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  // ─── Read Operations ───

  /// Get a single feed source by ID
  Future<FeedSourceConfig?> getFeedSource(String id) =>
      _localDataSource.getFeedSource(id);

  /// Get all feed sources
  Future<List<FeedSourceConfig>> getAllFeedSources() =>
      _localDataSource.getAllFeedSources();

  /// Get enabled feed sources
  Future<List<FeedSourceConfig>> getEnabledFeedSources() =>
      _localDataSource.getEnabledFeedSources();

  /// Get feed sources that need refresh
  Future<List<FeedSourceConfig>> getSourcesNeedingRefresh() =>
      _localDataSource.getSourcesNeedingRefresh();

  /// Get feed source count
  Future<int> getFeedSourceCount() =>
      _localDataSource.getFeedSourceCount();

  // ─── Write Operations ───

  /// Add a new feed source
  Future<void> addFeedSource(FeedSourceConfig config) =>
      _localDataSource.saveFeedSource(config);

  /// Update an existing feed source
  Future<void> updateFeedSource(FeedSourceConfig config) =>
      _localDataSource.saveFeedSource(config);

  /// Delete a feed source
  Future<void> deleteFeedSource(String id) =>
      _localDataSource.deleteFeedSource(id);

  /// Toggle feed source enabled/disabled
  Future<void> toggleFeedSource(String id, bool isEnabled) =>
      _localDataSource.toggleFeedSource(id, isEnabled);

  /// Update the last fetched timestamp
  Future<void> updateLastFetched(String id) =>
      _localDataSource.updateLastFetched(id);

  // ─── Initialization ───

  /// Initialize default feed sources if none exist
  Future<void> initializeDefaults() =>
      _localDataSource.initializeDefaults();

  // ─── Cleanup ───

  /// Delete all feed sources
  Future<void> deleteAll() =>
      _localDataSource.deleteAllFeedSources();
}
