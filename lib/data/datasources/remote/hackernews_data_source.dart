import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../domain/entities/feed_source.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/feed_source_config.dart';
import '../../../core/utils/logger.dart';

/// HackerNews API data source implementation
/// Supports both Firebase API and hnrss.org RSS feeds
class HackerNewsDataSource implements FeedSource {
  final FeedSourceConfig _config;
  final Dio _dio;

  static const _firebaseBaseUrl = 'https://hacker-news.firebaseio.com/v0';
  static const _hnrssBaseUrl = 'https://hnrss.org';

  HackerNewsDataSource({
    required FeedSourceConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio(Duration(seconds: 15));

  @override
  String get id => _config.id;

  @override
  String get name => _config.name;

  @override
  FeedSourceType get type => FeedSourceType.hackerNews;

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
      // If URL contains hnrss.org, use RSS parsing approach
      if (url.contains('hnrss.org')) {
        return _fetchFromHnrss(limit: limit, since: since);
      }
      // Otherwise use Firebase API directly
      return _fetchFromFirebaseApi(limit: limit, since: since);
    } catch (e) {
      logger.e('HackerNews [$name]: Failed to fetch articles', error: e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      if (url.contains('hnrss.org')) {
        final response = await _dio.get<String>(url);
        return response.statusCode == 200;
      }
      // Test Firebase API
      final response = await _dio.get('$_firebaseBaseUrl/topstories.json');
      return response.statusCode == 200;
    } catch (e) {
      logger.w('HackerNews [$name]: Connection test failed', error: e);
      return false;
    }
  }

  // ─── Firebase API ───

  Future<List<NewsArticle>> _fetchFromFirebaseApi({
    int? limit,
    DateTime? since,
  }) async {
    // Determine which endpoint to use based on config
    final endpoint = _config.extraConfig['endpoint'] ?? 'topstories';
    final response = await _dio.get<List<dynamic>>(
      '$_firebaseBaseUrl/$endpoint.json',
    );

    final storyIds = (response.data ?? []).cast<int>();
    final fetchLimit = limit ?? 30;
    final idsToFetch = storyIds.take(fetchLimit).toList();

    final articles = <NewsArticle>[];

    // Fetch stories in parallel batches
    const batchSize = 10;
    for (var i = 0; i < idsToFetch.length; i += batchSize) {
      final batch = idsToFetch.skip(i).take(batchSize);
      final futures = batch.map((id) => _fetchHnItem(id));
      final results = await Future.wait(futures);

      for (final article in results) {
        if (article == null) continue;
        if (since != null && article.publishedAt.isBefore(since)) continue;
        articles.add(article);
      }
    }

    logger.d('HackerNews API [$name]: Fetched ${articles.length} articles');
    return articles;
  }

  Future<NewsArticle?> _fetchHnItem(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_firebaseBaseUrl/item/$id.json',
      );

      final data = response.data;
      if (data == null) return null;

      final type = data['type'] as String? ?? '';
      if (type != 'story' && type != 'job') return null;

      final title = (data['title'] as String?)?.trim() ?? '';
      final url = data['url'] as String? ?? '';
      final by = data['by'] as String? ?? 'hn';
      final score = data['score'] as int? ?? 0;
      final descendants = data['descendants'] as int? ?? 0;
      final time = data['time'] as int? ?? 0;

      // HN text posts (Ask HN) use the text field instead of URL
      final isTextPost = url.isEmpty;
      final hnLink = 'https://news.ycombinator.com/item?id=$id';

      return NewsArticle(
        id: 'hn:$id',
        title: title,
        summary: isTextPost
            ? _stripHtml(data['text'] as String? ?? '')
            : 'Score: $score | Comments: $descendants',
        content: isTextPost
            ? (data['text'] as String? ?? '')
            : title,
        url: isTextPost ? hnLink : url,
        imageUrl: '', // HN stories typically don't have images
        sourceId: _config.id,
        sourceName: 'Hacker News',
        publishedAt: DateTime.fromMillisecondsSinceEpoch(time * 1000),
        fetchedAt: DateTime.now(),
        tags: isTextPost ? ['Ask HN'] : ['HN Score: $score'],
        category: _config.category,
        weight: _calculateHnWeight(score, descendants),
      );
    } catch (e) {
      logger.w('Failed to fetch HN item $id', error: e);
      return null;
    }
  }

  double _calculateHnWeight(int score, int comments) {
    // HN stories with higher engagement get higher initial weight
    final scoreWeight = (score / 100).clamp(0.5, 3.0);
    final commentWeight = (comments / 50).clamp(0.5, 2.0);
    return (scoreWeight + commentWeight) / 2;
  }

  // ─── hnrss.org ───

  Future<List<NewsArticle>> _fetchFromHnrss({
    int? limit,
    DateTime? since,
  }) async {
    try {
      final response = await _dio.get<String>(url);
      // Parse as RSS since hnrss.org returns RSS format
      // We use a simple regex-based approach to avoid importing webfeed here
      // (circular dep) - just parse the XML directly
      final articles = _parseHnrssXml(response.data ?? '', limit, since);
      logger.d('HNRSS [$name]: Fetched ${articles.length} articles');
      return articles;
    } catch (e) {
      logger.e('HNRSS [$name]: Failed to fetch', error: e);
      return [];
    }
  }

  List<NewsArticle> _parseHnrssXml(String xml, int? limit, DateTime? since) {
    final articles = <NewsArticle>[];
    final itemRegex = RegExp(r'<item>(.*?)</item>', dotAll: true);

    for (final match in itemRegex.allMatches(xml)) {
      if (limit != null && articles.length >= limit) break;

      final itemXml = match.group(1) ?? '';
      final title = _extractXmlTag(itemXml, 'title');
      final link = _extractXmlTag(itemXml, 'link');
      final description = _extractXmlTag(itemXml, 'description');
      final pubDate = _extractXmlTag(itemXml, 'pubDate');

      final publishedAt = DateTime.tryParse(pubDate) ?? DateTime.now();
      if (since != null && publishedAt.isBefore(since)) continue;

      articles.add(NewsArticle(
        id: 'hn:${link.hashCode.toRadixString(36)}',
        title: _decodeHtmlEntities(title),
        summary: _stripHtml(_decodeHtmlEntities(description)),
        content: _decodeHtmlEntities(description),
        url: link,
        imageUrl: '',
        sourceId: _config.id,
        sourceName: 'Hacker News',
        publishedAt: publishedAt,
        fetchedAt: DateTime.now(),
        tags: ['HackerNews'],
        category: _config.category,
      ));
    }

    return articles;
  }

  // ─── XML Helpers ───

  String _extractXmlTag(String xml, String tag) {
    final regex = RegExp('<$tag[^>]*>(.*?)</$tag>', dotAll: true);
    final match = regex.firstMatch(xml);
    return match?.group(1)?.trim() ?? '';
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }

  @override
  void dispose() {
    _dio.close();
  }
}
