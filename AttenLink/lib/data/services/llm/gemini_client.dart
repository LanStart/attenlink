import 'package:dio/dio.dart';
import '../ai_service.dart';

class GeminiClient implements AIService {
  final String apiKey;
  final Dio _dio = Dio();
  
  GeminiClient(this.apiKey, {String baseUrl = 'https://generativelanguage.googleapis.com/v1beta'}) {
    _dio.options.baseUrl = baseUrl.isNotEmpty ? baseUrl : 'https://generativelanguage.googleapis.com/v1beta';
  }
  
  @override
  Future<String> generateSummary(String text) async {
    try {
      final response = await _dio.post('/models/gemini-pro:generateContent?key=$apiKey', data: {
        "contents": [{
          "parts": [{"text": "请用简短的中文总结以下内容：\n\n$text"}]
        }]
      });
      return response.data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      return "生成总结失败: $e";
    }
  }
  
  @override
  Future<String> factCheck(String articleContent, {String? searchContext}) async {
    final systemPrompt = "你是一个事实核查助手，请分析以下新闻内容的真实性。若有搜索结果，请综合判断，并提供明确结论（相信/不相信）及AI总结的事实报告。必须标明【AI事实报告】。";
    final content = searchContext != null && searchContext.isNotEmpty 
        ? "$systemPrompt\n\n新闻内容：\n$articleContent\n\n【搜索引擎MCP返回结果】：\n$searchContext"
        : "$systemPrompt\n\n$articleContent";

    try {
      final response = await _dio.post('/models/gemini-pro:generateContent?key=$apiKey', data: {
        "contents": [{
          "parts": [{"text": content}]
        }]
      });
      return response.data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      return "核查失败: $e";
    }
  }
}
