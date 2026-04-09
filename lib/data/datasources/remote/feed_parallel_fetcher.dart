import 'dart:async';
import 'package:dio/dio.dart';
import 'package:webfeed/webfeed.dart';
import '../../models/news_article.dart';
import '../../models/feed_source_config.dart';
import 'package:uuid/uuid.dart';

class FeedParallelFetcher {
  final Dio _dio;
  final _uuid = const Uuid();

  FeedParallelFetcher({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch and parse articles from multiple sources in parallel
  Future<List<NewsArticle>> fetchAll(List<FeedSourceConfig> configs) async {
    final futures = configs.map((config) => fetchSource(config)).toList();
    final results = await Future.wait(futures);
    return results.expand((element) => element).toList();
  }

  /// Fetch a single source based on its type
  Future<List<NewsArticle>> fetchSource(FeedSourceConfig config) async {
    if (!config.isEnabled) return [];

    try {
      switch (config.type) {
        case FeedSourceType.rss:
        case FeedSourceType.atom:
          return await _fetchXmlFeed(config);
        case FeedSourceType.jsonFeed:
          return await _fetchJsonFeed(config);
        case FeedSourceType.hackerNews:
          return await _fetchHackerNews(config);
        case FeedSourceType.reddit:
          return await _fetchReddit(config);
        default:
          return [];
      }
    } catch (e) {
      // Log error but don't crash the entire aggregation
      print('Error fetching source ${config.name}: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> _fetchXmlFeed(FeedSourceConfig config) async {
    final response = await _dio.get(config.url);
    final xmlContent = response.data as String;
    
    // Auto-detect RSS vs Atom
    if (xmlContent.contains('<rss')) {
      final feed = RssFeed.parse(xmlContent);
      return feed.items?.map((item) => NewsArticle(
        id: item.guid ?? _uuid.v4(),
        title: item.title ?? '',
        summary: item.description ?? '',
        content: item.content?.value ?? item.description ?? '',
        url: item.link ?? '',
        sourceId: config.id,
        sourceName: config.name,
        publishedAt: _parseDate(item.pubDate),
        fetchedAt: DateTime.now(),
        imageUrl: _extractImageUrl(item.content?.value ?? item.description),
      )).toList() ?? [];
    } else {
      final feed = AtomFeed.parse(xmlContent);
      return feed.items?.map((item) => NewsArticle(
        id: item.id ?? _uuid.v4(),
        title: item.title ?? '',
        summary: item.summary ?? '',
        content: item.content ?? item.summary ?? '',
        url: item.links?.first.href ?? '',
        sourceId: config.id,
        sourceName: config.name,
        publishedAt: _parseDate(item.published ?? item.updated),
        fetchedAt: DateTime.now(),
      )).toList() ?? [];
    }
  }

  Future<List<NewsArticle>> _fetchJsonFeed(FeedSourceConfig config) async {
    final response = await _dio.get(config.url);
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    
    return items.map((item) => NewsArticle(
      id: item['id']?.toString() ?? _uuid.v4(),
      title: item['title'] ?? '',
      summary: item['summary'] ?? '',
      content: item['content_html'] ?? item['content_text'] ?? '',
      url: item['url'] ?? '',
      sourceId: config.id,
      sourceName: config.name,
      publishedAt: DateTime.tryParse(item['date_published'] ?? '') ?? DateTime.now(),
      fetchedAt: DateTime.now(),
      imageUrl: item['image'] ?? '',
    )).toList();
  }

  Future<List<NewsArticle>> _fetchHackerNews(FeedSourceConfig config) async {
    // Basic HN implementation focusing on top stories
    final response = await _dio.get('https://hacker-news.firebaseio.com/v0/topstories.json');
    final ids = (response.data as List).take(10).toList();
    
    final items = await Future.wait(ids.map((id) => _dio.get('https://hacker-news.firebaseio.com/v0/item/$id.json')));
    
    return items.map((res) {
      final item = res.data;
      return NewsArticle(
        id: 'hn-${item['id']}',
        title: item['title'] ?? '',
        summary: '',
        content: item['text'] ?? '',
        url: item['url'] ?? 'https://news.ycombinator.com/item?id=${item['id']}',
        sourceId: config.id,
        sourceName: config.name,
        publishedAt: DateTime.fromMillisecondsSinceEpoch((item['time'] ?? 0) * 1000),
        fetchedAt: DateTime.now(),
      );
    }).toList();
  }

  Future<List<NewsArticle>> _fetchReddit(FeedSourceConfig config) async {
    final response = await _dio.get('${config.url}/.json');
    final data = response.data['data']['children'] as List;
    
    return data.map((json) {
      final item = json['data'];
      return NewsArticle(
        id: 'reddit-${item['id']}',
        title: item['title'] ?? '',
        summary: item['selftext'] ?? '',
        content: item['selftext_html'] ?? '',
        url: 'https://reddit.com${item['permalink']}',
        sourceId: config.id,
        sourceName: config.name,
        publishedAt: DateTime.fromMillisecondsSinceEpoch((item['created_utc']?.toInt() ?? 0) * 1000),
        fetchedAt: DateTime.now(),
        imageUrl: item['thumbnail']?.startsWith('http') == true ? item['thumbnail'] : '',
      );
    }).toList();
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  String _extractImageUrl(String? html) {
    if (html == null) return '';
    final regExp = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = regExp.firstMatch(html);
    return match?.group(1) ?? '';
  }

  /// Get bootstrap/default feed sources
  static List<FeedSourceConfig> getBootstrapSources() {
    return [
      FeedSourceConfig(
        id: 'techcrunch',
        name: 'TechCrunch',
        url: 'https://techcrunch.com/feed/',
        type: FeedSourceType.rss,
        category: 'technology',
      ),
      FeedSourceConfig(
        id: 'hackernews',
        name: 'Hacker News',
        url: 'https://news.ycombinator.com/rss',
        type: FeedSourceType.hackerNews,
        category: 'technology',
      ),
      FeedSourceConfig(
        id: 'sspai',
        name: '少数派',
        url: 'https://sspai.com/feed',
        type: FeedSourceType.rss,
        category: 'lifestyle',
      ),
      FeedSourceConfig(
        id: 'reddit_worldnews',
        name: 'Reddit WorldNews',
        url: 'https://www.reddit.com/r/worldnews',
        type: FeedSourceType.reddit,
        category: 'world',
      ),
    ];
  }
}
