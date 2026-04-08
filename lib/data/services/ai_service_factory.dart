import 'ai_service.dart';
import 'llm/openai_client.dart';
import 'llm/claude_client.dart';
import 'llm/gemini_client.dart';
import 'llm/glm_client.dart';
import '../repositories/settings_repository.dart';

class AIServiceFactory {
  static Future<AIService?> create() async {
    final settings = SettingsRepository();
    final config = await settings.getAIConfig();
    
    final provider = config['provider'];
    final apiKey = config['api_key'];
    final baseUrl = config['base_url'] ?? '';

    if (apiKey == null || apiKey.isEmpty) return null;

    switch (provider) {
      case 'openai':
        return OpenAIClient(apiKey, baseUrl: baseUrl);
      case 'claude':
        return ClaudeClient(apiKey, baseUrl: baseUrl);
      case 'gemini':
        return GeminiClient(apiKey, baseUrl: baseUrl);
      case 'glm':
        return GLMClient(apiKey, baseUrl: baseUrl);
      default:
        return OpenAIClient(apiKey, baseUrl: baseUrl);
    }
  }
}
