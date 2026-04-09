import 'package:dio/dio.dart';

import '../../../domain/entities/feed_source.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/feed_source_config.dart';
import '../../../data/datasources/local/feed_source_local_data_source.dart';
import '../../../data/datasources/local/article_local_data_source.dart';
import '../../../data/repositories/feed_source_repository.dart';
import '../../../data/repositories/article_repository.dart';
import 'rss_feed_data_source.dart';
import 'atom_feed_data_source.dart';
import 'json_feed_data_source.dart';
import 'hackernews_data_source.dart';
import 'reddit_data_source.dart';
import '../../../core/utils/logger.dart';

/// Feed aggregator that coordinates all feed source types
/// Handles fetching, deduplication, and storage of articles
class FeedAggregator {
  final FeedSourceRepository _feedSourceRepo;
  final ArticleRepository _articleRepo;

  FeedAggregator({
    required FeedSourceRepository feedSourceRepo,
    required ArticleRepository articleRepo,
  })  : _feedSourceRepo = feedSourceRepo,
        _articleRepo = articleRepo;

  // ─── Core Operations ───

  /// Fetch articles from all enabled sources
  /// Returns total number of new articles fetched
  Future<int> fetchAllEnabledSources() async {
    final sources = await _feedSourceRepo.getEnabledFeedSources();
    if (sources.isEmpty) {
      logger.d('FeedAggregator: No enabled sources to fetch');
      return 0;
    }

    logger.d('FeedAggregator: Fetching from ${sources.length} sources');
    int totalNew = 0;

    for (final sourceConfig in sources) {
      try {
        final newCount = await fetchFromSource(sourceConfig);
        totalNew += newCount;
      } catch (e) {
        logger.e('FeedAggregator: Error fetching ${sourceConfig.name}', error: e);
      }
    }

    logger.d('FeedAggregator: Total new articles = $totalNew');
    return totalNew;
  }

  /// Fetch articles from sources that need refresh
  Future<int> fetchSourcesNeedingRefresh() async {
    final sources = await _feedSourceRepo.getSourcesNeedingRefresh();
    if (sources.isEmpty) {
      logger.d('FeedAggregator: No sources need refresh');
      return 0;
    }

    logger.d('FeedAggregator: Refreshing ${sources.length} sources');
    int totalNew = 0;

    for (final sourceConfig in sources) {
      try {
        final newCount = await fetchFromSource(sourceConfig);
        totalNew += newCount;
      } catch (e) {
        logger.e('FeedAggregator: Error refreshing ${sourceConfig.name}', error: e);
      }
    }

    return totalNew;
  }

  /// Fetch articles from a single source
  /// Returns the number of new articles (not already in storage)
  Future<int> fetchFromSource(FeedSourceConfig sourceConfig) async {
    final feedSource = _createFeedSource(sourceConfig);
    if (feedSource == null) {
      logger.w('FeedAggregator: Unknown source type ${sourceConfig.type}');
      return 0;
    }

    try {
      // Only fetch articles since the last fetch time
      final articles = await feedSource.fetchArticles(
        limit: 50,
        since: sourceConfig.lastFetchedAt.millisecondsSinceEpoch > 0
            ? sourceConfig.lastFetchedAt
            : null,
      );

      // Deduplicate against existing articles
      final newArticles = await _deduplicateArticles(articles);

      if (newArticles.isNotEmpty) {
        await _articleRepo.saveArticles(newArticles);
        logger.d('FeedAggregator: ${sourceConfig.name} → ${newArticles.length} new articles');
      }

      // Update last fetched timestamp
      await _feedSourceRepo.updateLastFetched(sourceConfig.id);

      // Cleanup
      feedSource.dispose();

      return newArticles.length;
    } catch (e) {
      logger.e('FeedAggregator: Failed to fetch from ${sourceConfig.name}', error: e);
      feedSource.dispose();
      return 0;
    }
  }

  /// Test connection to a feed source
  Future<FeedSourceTestResult> testSourceConnection(FeedSourceConfig sourceConfig) async {
    final feedSource = _createFeedSource(sourceConfig);
    if (feedSource == null) {
      return FeedSourceTestResult(
        success: false,
        message: '不支持的源类型: ${sourceConfig.type.label}',
      );
    }

    try {
      final isConnected = await feedSource.testConnection();
      feedSource.dispose();

      if (isConnected) {
        return FeedSourceTestResult(
          success: true,
          message: '连接成功！',
        );
      } else {
        return FeedSourceTestResult(
          success: false,
          message: '无法解析该源的格式，请检查 URL 是否正确',
        );
      }
    } catch (e) {
      feedSource.dispose();
      return FeedSourceTestResult(
        success: false,
        message: '连接失败: ${_friendlyErrorMessage(e)}',
      );
    }
  }

  /// Preview articles from a source without saving
  Future<List<NewsArticle>> previewSource(FeedSourceConfig sourceConfig, {int limit = 5}) async {
    final feedSource = _createFeedSource(sourceConfig);
    if (feedSource == null) return [];

    try {
      final articles = await feedSource.fetchArticles(limit: limit);
      feedSource.dispose();
      return articles;
    } catch (e) {
      logger.e('FeedAggregator: Preview failed for ${sourceConfig.name}', error: e);
      feedSource.dispose();
      return [];
    }
  }

  // ─── Source Factory ───

  /// Create the appropriate FeedSource implementation based on config type
  FeedSource? _createFeedSource(FeedSourceConfig config) {
    switch (config.type) {
      case FeedSourceType.rss:
        return RssFeedDataSource(config: config);
      case FeedSourceType.atom:
        return AtomFeedDataSource(config: config);
      case FeedSourceType.jsonFeed:
        return JsonFeedDataSource(config: config);
      case FeedSourceType.hackerNews:
        return HackerNewsDataSource(config: config);
      case FeedSourceType.reddit:
        return RedditDataSource(config: config);
      case FeedSourceType.custom:
        // Try auto-detecting the feed type
        return _autoDetectSource(config);
    }
  }

  /// Auto-detect feed type by trying different parsers
  FeedSource? _autoDetectSource(FeedSourceConfig config) {
    final detectedType = FeedSourceType.detectFromUrl(config.url);

    final detectedConfig = config.copyWith(type: detectedType);
    switch (detectedType) {
      case FeedSourceType.atom:
        return AtomFeedDataSource(config: detectedConfig);
      case FeedSourceType.jsonFeed:
        return JsonFeedDataSource(config: detectedConfig);
      case FeedSourceType.hackerNews:
        return HackerNewsDataSource(config: detectedConfig);
      case FeedSourceType.reddit:
        return RedditDataSource(config: detectedConfig);
      case FeedSourceType.rss:
      case FeedSourceType.custom:
        return RssFeedDataSource(config: detectedConfig);
    }
  }

  // ─── Deduplication ───

  /// Remove articles that already exist in the local store
  Future<List<NewsArticle>> _deduplicateArticles(List<NewsArticle> articles) async {
    final newArticles = <NewsArticle>[];

    for (final article in articles) {
      final existing = await _articleRepo.getArticle(article.id);
      if (existing == null) {
        newArticles.add(article);
      }
    }

    return newArticles;
  }

  // ─── Helpers ───

  String _friendlyErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('socketexception') || msg.contains('connection')) {
      return '网络连接失败，请检查网络';
    }
    if (msg.contains('404')) {
      return '源地址不存在 (404)';
    }
    if (msg.contains('403')) {
      return '访问被拒绝 (403)';
    }
    if (msg.contains('timeout')) {
      return '连接超时，请稍后重试';
    }
    if (msg.contains('format') || msg.contains('parse')) {
      return '无法解析源格式';
    }
    return '未知错误';
  }

  /// Cleanup old articles beyond retention period
  Future<int> cleanupOldArticles({int retainDays = 30}) async {
    final allArticles = await _articleRepo.getAllArticles();
    final cutoff = DateTime.now().subtract(Duration(days: retainDays));

    int deleted = 0;
    for (final article in allArticles) {
      // Don't delete liked articles or articles being verified
      if (article.userAction == UserAction.liked) continue;
      if (article.verificationStatus == VerificationStatus.verifying) continue;

      if (article.fetchedAt.isBefore(cutoff) && article.userAction == UserAction.none) {
        await _articleRepo.deleteArticle(article.id);
        deleted++;
      }
    }

    if (deleted > 0) {
      logger.d('FeedAggregator: Cleaned up $deleted old articles');
    }
    return deleted;
  }
}

/// Result of a feed source connection test
class FeedSourceTestResult {
  final bool success;
  final String message;
  final List<NewsArticle>? previewArticles;

  const FeedSourceTestResult({
    required this.success,
    required this.message,
    this.previewArticles,
  });
}
