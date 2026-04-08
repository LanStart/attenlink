import 'package:dio/dio.dart';
import 'package:webfeed_revised/webfeed_revised.dart';

class RssService {
  final Dio _dio = Dio();
  
  Future<RssFeed?> fetchFeed(String url) async {
    try {
      final response = await _dio.get(url);
      return RssFeed.parse(response.data.toString());
    } catch (e) {
      print("Error fetching RSS: $e");
      return null;
    }
  }

  Future<List<RssItem>> fetchAllFeeds(List<String> urls) async {
    List<RssItem> allItems = [];
    for (String url in urls) {
      final feed = await fetchFeed(url);
      if (feed != null && feed.items != null) {
        allItems.addAll(feed.items!);
      }
    }
    // Sort by pubDate descending
    allItems.sort((a, b) {
      if (a.pubDate == null || b.pubDate == null) return 0;
      return b.pubDate!.compareTo(a.pubDate!);
    });
    return allItems;
  }
}
