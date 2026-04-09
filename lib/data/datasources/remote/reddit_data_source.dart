import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../domain/entities/feed_source.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/feed_source_config.dart';
import '../../../core/utils/logger.dart';

/// Reddit data source implementation
/// Supports Reddit JSON API for subreddits
///
/// Usage: https://www.reddit.com/r/technology/hot.json
/// Or: https://www.reddit.com/r/worldnews/new.json?limit=25
class RedditDataSource implements FeedSource {
  final FeedSourceConfig _config;
  final Dio _dio;

  static const _baseUrl = 'https://www.reddit.com';

  RedditDataSource({
    required FeedSourceConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio(Duration(seconds: 15)) {
    // Reddit requires a User-Agent header
    _dio.options.headers['User-Agent'] = 'AttenLink/0.1 (News Aggregator)';
  }

  @override
  String get id => _config.id;

  @override
  String get name => _config.name;

  @override
  FeedSourceType get type => FeedSourceType.reddit;

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
      // Build the Reddit JSON API URL
      final apiUrl = _buildApiUrl(limit);
      final response = await _dio.get<String>(apiUrl);

      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      final children = data?['children'] as List<dynamic>? ?? [];

      final articles = <NewsArticle>[];

      for (final child in children) {
        final postData = (child as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        if (postData == null) continue;

        final article = _parseRedditPost(postData);
        if (article == null) continue;

        if (since != null && article.publishedAt.isBefore(since)) continue;
        articles.add(article);
      }

      logger.d('Reddit [$name]: Fetched ${articles.length} articles');
      return articles;
    } catch (e) {
      logger.e('Reddit [$name]: Failed to fetch articles', error: e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final apiUrl = _buildApiUrl(1);
      final response = await _dio.get<String>(apiUrl);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.data!) as Map<String, dynamic>;
        return json['data']?['children'] != null;
      }
      return false;
    } catch (e) {
      logger.w('Reddit [$name]: Connection test failed', error: e);
      return false;
    }
  }

  // ─── URL Building ───

  String _buildApiUrl(int? limit) {
    final fetchLimit = limit ?? 25;

    // If the URL already ends with .json, use it directly
    if (url.endsWith('.json')) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}limit=$fetchLimit';
    }

    // Otherwise, convert subreddit URL to JSON API URL
    // e.g., https://www.reddit.com/r/technology/hot
    //   →  https://www.reddit.com/r/technology/hot.json?limit=25
    final sort = _config.extraConfig['sort'] ?? 'hot';
    String path = url;

    // Remove trailing slash
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    // If URL doesn't have a sort suffix, add one
    if (!path.endsWith(RegExp(r'/(hot|new|rising|controversial|top)'))) {
      path = '$path/$sort';
    }

    return '$path.json?limit=$fetchLimit';
  }

  // ─── Post Parsing ───

  NewsArticle? _parseRedditPost(Map<String, dynamic> data) {
    final title = (data['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) return null;

    final id = data['id'] as String? ?? '';
    final permalink = data['permalink'] as String? ?? '';
    final urlOverride = data['url_overridden_by_dest'] as String?;
    final selftext = data['selftext'] as String? ?? '';
    final author = data['author'] as String? ?? 'reddit';
    final score = data['score'] as int? ?? 0;
    final numComments = data['num_comments'] as int? ?? 0;
    final createdUtc = data['created_utc'] as double? ?? 0;
    final isVideo = data['is_video'] as bool? ?? false;
    final postHint = data['post_hint'] as String? ?? '';
    final thumbnail = data['thumbnail'] as String? ?? '';
    final linkFlairText = data['link_flair_text'] as String?;
    final subreddit = data['subreddit'] as String? ?? '';

    // Determine if it's a self post (text-only)
    final isSelfPost = data['is_self'] as bool? ?? false;

    // Extract image URL
    String imageUrl = '';
    if (!isSelfPost && thumbnail.isNotEmpty && !thumbnail.startsWith('http://thumbs.reddit')) {
      // Try preview images first (higher quality)
      final preview = data['preview'] as Map<String, dynamic>?;
      final images = preview?['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final source = (images[0] as Map<String, dynamic>)['source'] as Map<String, dynamic>?;
        if (source != null) {
          imageUrl = source['url'] as String? ?? '';
          // Reddit uses amp; encoding in preview URLs
          imageUrl = imageUrl.replaceAll('&amp;', '&');
        }
      }

      // Fallback to thumbnail
      if (imageUrl.isEmpty && _isValidImageUrl(thumbnail)) {
        imageUrl = thumbnail;
      }
    }

    // Build tags
    final tags = <String>['r/$subreddit'];
    if (linkFlairText != null && linkFlairText.isNotEmpty) {
      tags.add(linkFlairText);
    }

    return NewsArticle(
      id: 'reddit:$id',
      title: title,
      summary: _extractSummary(selftext, isSelfPost),
      content: selftext,
      url: isSelfPost ? '$_baseUrl$permalink' : (urlOverride ?? '$_baseUrl$permalink'),
      imageUrl: imageUrl,
      sourceId: _config.id,
      sourceName: 'r/$subreddit',
      publishedAt: DateTime.fromMillisecondsSinceEpoch((createdUtc * 1000).round()),
      fetchedAt: DateTime.now(),
      tags: tags,
      category: _config.category,
      weight: _calculateRedditWeight(score, numComments),
    );
  }

  String _extractSummary(String selftext, bool isSelfPost) {
    if (!isSelfPost) {
      return ''; // Link posts don't have meaningful summaries
    }
    final plain = selftext.replaceAll(RegExp(r'[\n\r]+'), ' ').trim();
    if (plain.length > 300) {
      return '${plain.substring(0, 300)}...';
    }
    return plain;
  }

  double _calculateRedditWeight(int score, int comments) {
    final scoreWeight = (score / 500).clamp(0.5, 3.0);
    final commentWeight = (comments / 100).clamp(0.5, 2.0);
    return (scoreWeight + commentWeight) / 2;
  }

  bool _isValidImageUrl(String url) {
    return url.startsWith('https://') &&
        (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.jpeg') || url.endsWith('.webp'));
  }

  @override
  void dispose() {
    _dio.close();
  }
}
