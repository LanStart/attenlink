import '../../data/models/news_article.dart';
import '../../data/models/feed_source_config.dart';

/// Abstract feed source interface
/// All feed source types must implement this interface
abstract class FeedSource {
  /// Unique identifier
  String get id;

  /// Display name
  String get name;

  /// Feed source type
  FeedSourceType get type;

  /// Source URL or endpoint
  String get url;

  /// Whether the source is currently enabled
  bool get isEnabled;

  /// Fetch articles from this source
  /// [limit] - maximum number of articles to fetch
  /// [since] - only fetch articles published after this time
  Future<List<NewsArticle>> fetchArticles({
    int? limit,
    DateTime? since,
  });

  /// Test if the source connection is valid
  Future<bool> testConnection();

  /// Dispose any resources
  void dispose() {}
}
