import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../domain/entities/feed_source.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/feed_source_config.dart';
import '../../../core/utils/logger.dart';

/// JSON Feed source implementation
/// Parses JSON Feed v1.1 format (https://jsonfeed.org/version/1.1)
class JsonFeedDataSource implements FeedSource {
  final FeedSourceConfig _config;
  final Dio _dio;

  JsonFeedDataSource({
    required FeedSourceConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio(Duration(seconds: 15));

  @override
  String get id => _config.id;

  @override
  String get name => _config.name;

  @override
  FeedSourceType get type => FeedSourceType.jsonFeed;

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
      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      final feed = JsonFeed.parse(json);

      final articles = <NewsArticle>[];

      for (final item in feed.items) {
        if (limit != null && articles.length >= limit) break;

        final publishedAt = _parseDate(item.datePublished ?? item.dateModified);
        if (since != null && publishedAt.isBefore(since)) continue;

        final article = NewsArticle(
          id: _generateArticleId(item.id),
          title: item.title?.trim() ?? 'Untitled',
          summary: _extractSummary(item),
          content: item.contentHtml ?? item.contentText ?? '',
          url: item.url ?? item.id,
          imageUrl: _extractImageUrl(item),
          sourceId: _config.id,
          sourceName: _config.name,
          publishedAt: publishedAt,
          fetchedAt: DateTime.now(),
          tags: item.tags ?? [],
          category: _config.category,
        );

        articles.add(article);
      }

      logger.d('JSON Feed [$name]: Fetched ${articles.length} articles');
      return articles;
    } catch (e) {
      logger.e('JSON Feed [$name]: Failed to fetch articles', error: e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!) as Map<String, dynamic>;
        return json['version'] != null && json['items'] != null;
      }
      return false;
    } catch (e) {
      logger.w('JSON Feed [$name]: Connection test failed', error: e);
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

  String _extractSummary(JsonFeedItem item) {
    final text = item.summary ?? item.contentText ?? '';
    if (text.length > 300) {
      return '${text.substring(0, 300)}...';
    }
    return text;
  }

  String _extractImageUrl(JsonFeedItem item) {
    // Try image field first
    if (item.image != null && item.image!.isNotEmpty) return item.image!;

    // Try banner_image
    if (item.bannerImage != null && item.bannerImage!.isNotEmpty) {
      return item.bannerImage!;
    }

    // Try attachments
    if (item.attachments != null) {
      for (final att in item.attachments!) {
        if (att.mimeType?.startsWith('image/') ?? false) {
          return att.url;
        }
      }
    }

    // Try extracting from content_html
    final html = item.contentHtml ?? '';
    final imgMatch = RegExp(r'''<img[^>]+src=["']([^"']+)["']''').firstMatch(html);
    if (imgMatch != null) return imgMatch.group(1) ?? '';

    return '';
  }

  String _generateArticleId(String itemId) {
    return '${_config.id}:${itemId.hashCode.toRadixString(36)}';
  }

  @override
  void dispose() {
    _dio.close();
  }
}

// ─── JSON Feed Model ───

/// Lightweight JSON Feed v1.1 parser
class JsonFeed {
  final String? title;
  final String? homePageUrl;
  final String? feedUrl;
  final List<JsonFeedItem> items;

  const JsonFeed({
    this.title,
    this.homePageUrl,
    this.feedUrl,
    required this.items,
  });

  factory JsonFeed.parse(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return JsonFeed(
      title: json['title'] as String?,
      homePageUrl: json['home_page_url'] as String?,
      feedUrl: json['feed_url'] as String?,
      items: itemsList.map((i) => JsonFeedItem.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

/// JSON Feed item
class JsonFeedItem {
  final String id;
  final String? url;
  final String? title;
  final String? contentHtml;
  final String? contentText;
  final String? summary;
  final String? datePublished;
  final String? dateModified;
  final String? image;
  final String? bannerImage;
  final List<String>? tags;
  final List<JsonFeedAttachment>? attachments;

  const JsonFeedItem({
    required this.id,
    this.url,
    this.title,
    this.contentHtml,
    this.contentText,
    this.summary,
    this.datePublished,
    this.dateModified,
    this.image,
    this.bannerImage,
    this.tags,
    this.attachments,
  });

  factory JsonFeedItem.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] as List<dynamic>?;
    final attList = json['attachments'] as List<dynamic>?;

    return JsonFeedItem(
      id: json['id'] as String? ?? '',
      url: json['url'] as String?,
      title: json['title'] as String?,
      contentHtml: json['content_html'] as String?,
      contentText: json['content_text'] as String?,
      summary: json['summary'] as String?,
      datePublished: json['date_published'] as String?,
      dateModified: json['date_modified'] as String?,
      image: json['image'] as String?,
      bannerImage: json['banner_image'] as String?,
      tags: tagsList?.cast<String>(),
      attachments: attList?.map((a) => JsonFeedAttachment.fromJson(a as Map<String, dynamic>)).toList(),
    );
  }
}

/// JSON Feed attachment
class JsonFeedAttachment {
  final String url;
  final String? mimeType;
  final String? title;

  const JsonFeedAttachment({
    required this.url,
    this.mimeType,
    this.title,
  });

  factory JsonFeedAttachment.fromJson(Map<String, dynamic> json) {
    return JsonFeedAttachment(
      url: json['url'] as String? ?? '',
      mimeType: json['mime_type'] as String?,
      title: json['title'] as String?,
    );
  }
}
