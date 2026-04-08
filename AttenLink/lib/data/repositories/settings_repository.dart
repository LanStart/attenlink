import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _rssUrlsKey = 'rss_urls';
  static const String _aiProviderKey = 'ai_provider';
  static const String _aiApiKeyKey = 'ai_api_key';
  static const String _aiBaseUrlKey = 'ai_base_url';

  Future<void> saveRssUrls(List<String> urls) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_rssUrlsKey, urls);
  }
  
  Future<List<String>> getRssUrls() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_rssUrlsKey) ?? [];
  }
  
  Future<void> saveAIConfig(String provider, String apiKey, String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiProviderKey, provider);
    await prefs.setString(_aiApiKeyKey, apiKey);
    await prefs.setString(_aiBaseUrlKey, baseUrl);
  }

  Future<Map<String, String>> getAIConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'provider': prefs.getString(_aiProviderKey) ?? 'openai',
      'api_key': prefs.getString(_aiApiKeyKey) ?? '',
      'base_url': prefs.getString(_aiBaseUrlKey) ?? '',
    };
  }
}
