enum AIProvider { openai, claude, gemini, glm }

class AIConfig {
  final AIProvider provider;
  final String apiKey;
  final String baseUrl;
  
  AIConfig({
    required this.provider, 
    required this.apiKey, 
    this.baseUrl = ''
  });
}
