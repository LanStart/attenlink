import 'package:dio/dio.dart';
import 'package:webfeed_revised/webfeed_revised.dart';

// Unified item model to handle both RSS and Atom
class FeedItem {
  final String title;
  final String description;
  final String? link;
  final DateTime? pubDate;

  FeedItem({
    required this.title,
    required this.description,
    this.link,
    this.pubDate,
  });
}

class RssService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      // Many modern feeds block requests without a proper User-Agent
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': 'application/rss+xml, application/rdf+xml, application/atom+xml, application/xml, text/xml, */*'
    },
  ));

  Future<List<FeedItem>> fetchFeed(String url) async {
    try {
      final response = await _dio.get(url);
      final xmlString = response.data.toString();
      
      // Try parsing as RSS first
      try {
        final rssFeed = RssFeed.parse(xmlString);
        if (rssFeed.items != null && rssFeed.items!.isNotEmpty) {
          return rssFeed.items!.map((item) => FeedItem(
            title: item.title ?? 'No Title',
            description: item.description ?? '',
            link: item.link,
            pubDate: item.pubDate,
          )).toList();
        }
      } catch (_) {
        // Not an RSS feed or empty
      }

      // Try parsing as Atom if RSS fails
      try {
        final atomFeed = AtomFeed.parse(xmlString);
        if (atomFeed.items != null && atomFeed.items!.isNotEmpty) {
          return atomFeed.items!.map((item) => FeedItem(
            title: item.title ?? 'No Title',
            description: item.summary ?? item.content ?? '',
            link: item.links?.isNotEmpty == true ? item.links!.first.href : null,
            pubDate: item.updated ?? item.published,
          )).toList();
        }
      } catch (_) {
        // Not an Atom feed either
      }
      
      return [];
    } catch (e) {
      print("Error fetching Feed from $url: $e");
      return [];
    }
  }

  Future<List<FeedItem>> fetchAllFeeds(List<String> urls) async {
    List<FeedItem> allItems = [];
    
    // Fetch all URLs in parallel for better performance
    final futures = urls.map((url) => fetchFeed(url));
    final results = await Future.wait(futures);
    
    for (var items in results) {
      allItems.addAll(items);
    }
    
    // Sort by pubDate descending
    allItems.sort((a, b) {
      if (a.pubDate == null && b.pubDate == null) return 0;
      if (a.pubDate == null) return 1;
      if (b.pubDate == null) return -1;
      return b.pubDate!.compareTo(a.pubDate!);
    });
    
    return allItems;
  }
}
