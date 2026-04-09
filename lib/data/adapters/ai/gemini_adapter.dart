import 'package:dio/dio.dart';
import '../../../domain/entities/ai_service_provider.dart';
import '../../models/verification_result.dart';
import '../../models/ai_provider_config.dart';

class GeminiAdapter implements AiServiceProvider {
  final AiProviderConfig config;
  final Dio _dio;

  GeminiAdapter({
    required this.config,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(
          baseUrl: config.baseUrl.isNotEmpty 
              ? config.baseUrl 
              : 'https://generativelanguage.googleapis.com/v1beta',
          headers: {
            'x-goog-api-key': config.apiKey,
            'Content-Type': 'application/json',
          },
        ));

  @override
  String get id => config.id;

  @override
  String get displayName => config.displayName;

  @override
  String get type => 'gemini';

  @override
  bool get supportsVision => true;

  @override
  bool get supportsToolUse => true;

  @override
  Future<String> chat(
    List<ChatMessage> messages, {
    List<McpTool>? tools,
  }) async {
    // Convert messages to Gemini format
    final contents = messages.map((m) => {
      'role': m.role == 'assistant' ? 'model' : 'user',
      'parts': [{'text': m.content}],
    }).toList();

    final response = await _dio.post(
      '/models/${config.model}:generateContent',
      data: {'contents': contents},
    );

    return response.data['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  @override
  Future<List<double>> embedText(String text) async {
    final response = await _dio.post(
      '/models/embedding-001:embedContent',
      data: {
        'model': 'models/embedding-001',
        'content': {
          'parts': [{'text': text}]
        }
      },
    );

    return (response.data['embedding']['values'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
  }

  @override
  Future<String?> analyzeImage(String imagePath, String prompt) async {
    // Implementation for vision analysis (using base64 or file upload)
    return "Vision analysis result from Gemini 3 Flash";
  }

  @override
  Future<VerificationResult> verifyArticle({
    required String articleTitle,
    required String articleContent,
    required String articleUrl,
  }) async {
    // This will be called by the VerificationEngine
    // It will typically involve multiple steps or a complex prompt
    final prompt = """
    你是一个事实查证专家。请对以下资讯进行查证：
    标题: $articleTitle
    URL: $articleUrl
    内容: $articleContent
    
    请输出 JSON 格式的查证结果。
    """;
    
    final responseText = await chat([ChatMessage(role: 'user', content: prompt)]);
    
    // Parse responseText into VerificationResult...
    // placeholder implementation
    return VerificationResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      articleId: '', // Set by caller
      verdict: Verdict.verified,
      aiSummary: '查证摘要: $responseText',
      verifiedAt: DateTime.now(),
      confidenceScore: 0.95,
    );
  }

  @override
  void dispose() {
    _dio.close();
  }
}
