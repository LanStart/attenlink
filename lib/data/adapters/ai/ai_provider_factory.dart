import '../../../domain/entities/ai_service_provider.dart';
import '../../models/ai_provider_config.dart';
import 'gemini_adapter.dart';
import 'openai_adapter.dart';

/// Factory to create AI providers based on user configuration
class AiProviderFactory {
  /// Create a provider instance from configuration
  static AiServiceProvider create(AiProviderConfig config) {
    switch (config.type.toLowerCase()) {
      case 'gemini':
        return GeminiAdapter(config: config);
      case 'openai':
      case 'kimi':
      case 'glm':
      case 'deepseek':
        // These all typically use OpenAI compatible protocols
        return OpenAiAdapter(config: config);
      default:
        throw Exception('Unsupported AI provider type: ${config.type}');
    }
  }
}
