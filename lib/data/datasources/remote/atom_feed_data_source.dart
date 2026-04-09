import 'package:dio/dio.dart';
import 'package:webfeed/webfeed.dart';

import '../../../domain/entities/feed_source.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/feed_source_config.dart';
import '../../../core/utils/logger.dart';

/// Atom feed source implementation
/// Parses Atom 1.0 feeds (commonly used by blogs and news sites)
class AtomFeedDataSource implements FeedSource {
  final FeedSourceConfig _config;
  final Dio _dio;

  AtomFeedDataSource({
    required FeedSourceConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio(Duration(seconds: 15));

  @override
  String get id => _config.id;

  @override
  String get name => _config.name;

  @override
  FeedSourceType get type => FeedSourceType.atom;

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
      final atomFeed = AtomFeed.parse(response.data!);

      final articles = <NewsArticle>[];
      final entries = atomFeed.items ?? [];

      for (final entry in entries) {
        if (limit != null && articles.length >= limit) break;

        final publishedAt = _parseDate(entry.published ?? entry.updated);
        if (since != null && publishedAt.isBefore(since)) continue;

        final article = NewsArticle(
          id: _generateArticleId(entry.id ?? entry.title ?? ''),
          title: entry.title?.trim() ?? 'Untitled',
          summary: _extractSummary(entry),
          content: entry.content?.trim() ?? entry.summary?.trim() ?? '',
          url: _extractLink(entry),
          imageUrl: _extractImageUrl(entry),
          sourceId: _config.id,
          sourceName: _config.name,
          publishedAt: publishedAt,
          fetchedAt: DateTime.now(),
          tags: _extractCategories(entry),
          category: _config.category,
        );

        articles.add(article);
      }

      logger.d('Atom [$name]: Fetched ${articles.length} articles');
      return articles;
    } catch (e) {
      logger.e('Atom [$name]: Failed to fetch articles', error: e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        AtomFeed.parse(response.data!);
        return true;
      }
      return false;
    } catch (e) {
      logger.w('Atom [$name]: Connection test failed', error: e);
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

  String _extractSummary(AtomItem entry) {
    final summary = entry.summary?.trim() ?? '';
    if (summary.length > 300) {
      return '${summary.substring(0, 300)}...';
    }
    return summary;
  }

  String _extractLink(AtomItem entry) {
    if (entry.links == null || entry.links!.isEmpty) return '';
    final alternate = entry.links!.firstWhere(
      (l) => l.rel == 'alternate',
      orElse: () => entry.links!.first,
    );
    return alternate.href ?? '';
  }

  String _extractImageUrl(AtomItem entry) {
    // Try media:content / media:thumbnail
    final mediaContent = entry.media?.contents;
    if (mediaContent != null && mediaContent.isNotEmpty) {
      final image = mediaContent.firstWhere(
        (c) => (c.medium?.toLowerCase() ?? '') == 'image' || (c.type?.startsWith('image/') ?? false),
        orElse: () => mediaContent.first,
      );
      if (image.url != null) return image.url!;
    }

    final mediaThumbnail = entry.media?.thumbnails;
    if (mediaThumbnail != null && mediaThumbnail.isNotEmpty) {
      return mediaThumbnail.first.url ?? '';
    }

    // Try extracting from content HTML
    final content = entry.content ?? entry.summary ?? '';
    final imgMatch = RegExp(r'''<img[^>]+src=["']([^"']+)["']''').firstMatch(content);
    if (imgMatch != null) return imgMatch.group(1) ?? '';

    return '';
  }

  List<String> _extractCategories(AtomItem entry) {
    return entry.categories?.map((c) => c.label ?? c.term ?? '').where((c) => c.isNotEmpty).toList() ?? [];
  }

  String _generateArticleId(String uniquePart) {
    return '${_config.id}:${uniquePart.hashCode.toRadixString(36)}';
  }

  @override
  void dispose() {
    _dio.close();
  }
}
