import 'package:dio/dio.dart';
import '../repositories/settings_repository.dart';

class SearchService {
  final Dio _dio = Dio();

  Future<String> search(String query) async {
    final settings = SettingsRepository();
    final searchConfig = await settings.getSearchConfig();
    final provider = searchConfig['provider'] ?? 'duckduckgo';
    final apiKey = searchConfig['api_key'] ?? '';

    try {
      switch (provider) {
        case 'duckduckgo':
          return await _searchDuckDuckGo(query);
        case 'bing':
          return await _searchBing(query, apiKey);
        case 'google':
          return await _searchGoogle(query, apiKey);
        case 'baidu':
          return await _searchBaidu(query, apiKey);
        default:
          return await _searchDuckDuckGo(query);
      }
    } catch (e) {
      return "Search failed: $e";
    }
  }

  Future<String> _searchDuckDuckGo(String query) async {
    // DuckDuckGo HTML Lite search parsing (mock implementation for brevity)
    final response = await _dio.get('https://html.duckduckgo.com/html/', queryParameters: {'q': query});
    if (response.statusCode == 200) {
      return "【DuckDuckGo 搜索结果】关于 '$query' 的相关资料显示该事件确实发生过，但细节可能有出入。请AI综合判断。";
    }
    return "No results found on DuckDuckGo.";
  }

  Future<String> _searchBing(String query, String apiKey) async {
    if (apiKey.isEmpty) return "Error: Bing API Key is missing.";
    // Mock Bing Search
    return "【Bing 搜索结果】'$query' 最新资讯表示事实基本一致，且有官方声明。";
  }

  Future<String> _searchGoogle(String query, String apiKey) async {
    if (apiKey.isEmpty) return "Error: Google API Key is missing.";
    // Mock Google Search
    return "【Google 搜索结果】'$query' 在多家权威媒体报道中得到证实。";
  }

  Future<String> _searchBaidu(String query, String apiKey) async {
    if (apiKey.isEmpty) return "Error: Baidu API Key is missing.";
    // Mock Baidu Search
    return "【Baidu 搜索结果】'$query' 的相关新闻显示有反转。";
  }
}
