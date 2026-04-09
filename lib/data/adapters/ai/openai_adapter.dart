import 'package:dio/dio.dart';
import '../../../domain/entities/ai_service_provider.dart';
import '../../models/verification_result.dart';
import '../../models/ai_provider_config.dart';

/// Adapter for OpenAI compatible APIs (GPT-4, Kimi, GLM, etc.)
class OpenAiAdapter implements AiServiceProvider {
  final AiProviderConfig config;
  final Dio _dio;

  OpenAiAdapter({
    required this.config,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(
          baseUrl: config.baseUrl.isNotEmpty 
              ? config.baseUrl 
              : 'https://api.openai.com/v1',
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
        ));

  @override
  String get id => config.id;

  @override
  String get displayName => config.displayName;

  @override
  String get type => config.type;

  @override
  bool get supportsVision => config.model.contains('vision') || config.model.contains('gpt-4o');

  @override
  bool get supportsToolUse => true;

  @override
  Future<String> chat(
    List<ChatMessage> messages, {
    List<McpTool>? tools,
  }) async {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': config.model,
        'messages': messages.map((m) => {
          'role': m.role,
          'content': m.content,
        }).toList(),
      },
    );

    return response.data['choices'][0]['message']['content'] as String;
  }

  @override
  Future<List<double>> embedText(String text) async {
    final response = await _dio.post(
      '/embeddings',
      data: {
        'model': 'text-embedding-3-small',
        'input': text,
      },
    );

    return (response.data['data'][0]['embedding'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
  }

  @override
  Future<String?> analyzeImage(String imagePath, String prompt) async {
    if (!supportsVision) return null;
    // Vision implementation placeholder
    return "Vision analysis result from ${config.model}";
  }

  @override
  Future<VerificationResult> verifyArticle({
    required String articleTitle,
    required String articleContent,
    required String articleUrl,
  }) async {
    final prompt = """
    你是一个专业的事实核查员。请分析以下内容：
    标题: $articleTitle
    URL: $articleUrl
    内容: $articleContent
    
    请给出结论：已核实 (Verified) / 有争议 (Disputed) / 已过时 (Outdated)。
    并提供简短摘要。
    """;
    
    final response = await chat([ChatMessage(role: 'user', content: prompt)]);
    
    return VerificationResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      articleId: '',
      verdict: response.contains('已核实') ? Verdict.verified : Verdict.disputed,
      aiSummary: response,
      verifiedAt: DateTime.now(),
      confidenceScore: 0.9,
    );
  }

  @override
  void dispose() {
    _dio.close();
  }
}
