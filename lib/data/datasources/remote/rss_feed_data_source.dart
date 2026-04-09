import 'package:dio/dio.dart';
import 'package:webfeed/webfeed.dart';

import '../../../domain/entities/feed_source.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/feed_source_config.dart';
import '../../../core/utils/logger.dart';

/// RSS feed source implementation
/// Parses standard RSS 2.0 feeds
class RssFeedDataSource implements FeedSource {
  final FeedSourceConfig _config;
  final Dio _dio;

  RssFeedDataSource({
    required FeedSourceConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio(Duration(seconds: 15));

  @override
  String get id => _config.id;

  @override
  String get name => _config.name;

  @override
  FeedSourceType get type => FeedSourceType.rss;

  @override
  String get url => _config.url;

  @override
  bool get isEnabled => _config.isEnabled;

  @override
  Future<List<NewsArticle>> fetchArticles({
    int? limit,
    DateTime? since,
  }) async {
    try {
      final response = await _dio.get<String>(url);
      final rssFeed = RssFeed.parse(response.data!);

      final articles = <NewsArticle>[];
      final items = rssFeed.items ?? [];

      for (final item in items) {
        if (limit != null && articles.length >= limit) break;

        final publishedAt = _parseDate(item.pubDate);
        if (since != null && publishedAt.isBefore(since)) continue;

        final article = NewsArticle(
          id: _generateArticleId(item.link ?? item.title ?? ''),
          title: item.title?.trim() ?? 'Untitled',
          summary: _extractSummary(item),
          content: item.description?.trim() ?? item.content?.value?.trim() ?? '',
          url: item.link ?? '',
          imageUrl: _extractImageUrl(item),
          sourceId: _config.id,
          sourceName: _config.name,
          publishedAt: publishedAt,
          fetchedAt: DateTime.now(),
          tags: _extractCategories(item),
          category: _config.category,
        );

        articles.add(article);
      }

      logger.d('RSS [$name]: Fetched ${articles.length} articles');
      return articles;
    } catch (e) {
      logger.e('RSS [$name]: Failed to fetch articles', error: e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        RssFeed.parse(response.data!);
        return true;
      }
      return false;
    } catch (e) {
      logger.w('RSS [$name]: Connection test failed', error: e);
      return false;
    }
  }

  // ─── Helpers ───

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  String _extractSummary(RssItem item) {
    final desc = item.description?.trim() ?? '';
    if (desc.length > 300) {
      return '${desc.substring(0, 300)}...';
    }
    return desc;
  }

  String _extractImageUrl(RssItem item) {
    // Try media:content first
    final mediaContent = item.media?.contents;
    if (mediaContent != null && mediaContent.isNotEmpty) {
      final image = mediaContent.firstWhere(
        (c) => (c.medium?.toLowerCase() ?? '') == 'image' || (c.type?.startsWith('image/') ?? false),
        orElse: () => mediaContent.first,
      );
      if (image.url != null) return image.url!;
    }

    // Try media:thumbnail
    final mediaThumbnail = item.media?.thumbnails;
    if (mediaThumbnail != null && mediaThumbnail.isNotEmpty) {
      return mediaThumbnail.first.url ?? '';
    }

    // Try enclosure
    final enclosure = item.enclosure;
    if (enclosure != null && (enclosure.type?.startsWith('image/') ?? false)) {
      return enclosure.url ?? '';
    }

    // Try extracting from description HTML
    final desc = item.description ?? '';
    final imgMatch = RegExp(r'''<img[^>]+src=["']([^"']+)["']''').firstMatch(desc);
    if (imgMatch != null) return imgMatch.group(1) ?? '';

    return '';
  }

  List<String> _extractCategories(RssItem item) {
    final categories = <String>[];
    for (final cat in item.categories ?? []) {
      if (cat.value != null && cat.value!.isNotEmpty) {
        categories.add(cat.value!);
      }
    }
    return categories;
  }

  String _generateArticleId(String uniquePart) {
    return '${_config.id}:${uniquePart.hashCode.toRadixString(36)}';
  }

  @override
  void dispose() {
    _dio.close();
  }
}
