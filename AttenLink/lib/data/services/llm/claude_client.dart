import 'package:dio/dio.dart';
import '../ai_service.dart';

class ClaudeClient implements AIService {
  final String apiKey;
  final Dio _dio = Dio();
  
  ClaudeClient(this.apiKey, {String baseUrl = 'https://api.anthropic.com/v1'}) {
    _dio.options.baseUrl = baseUrl.isNotEmpty ? baseUrl : 'https://api.anthropic.com/v1';
    _dio.options.headers['x-api-key'] = apiKey;
    _dio.options.headers['anthropic-version'] = '2023-06-01';
    _dio.options.headers['content-type'] = 'application/json';
  }
  
  @override
  Future<String> generateSummary(String text) async {
    try {
      final response = await _dio.post('/messages', data: {
        "model": "claude-3-haiku-20240307",
        "max_tokens": 1024,
        "messages": [
          {"role": "user", "content": "请用简短的中文总结以下内容：\n\n$text"}
        ]
      });
      return response.data['content'][0]['text'];
    } catch (e) {
      return "生成总结失败: $e";
    }
  }
  
  @override
  Future<String> factCheck(String articleContent, {String? searchContext}) async {
    final systemPrompt = "你是一个事实核查助手，请分析以下新闻内容的真实性。若有搜索结果，请综合判断，并提供明确结论（相信/不相信）及AI总结的事实报告。必须标明【AI事实报告】。";
    final content = searchContext != null && searchContext.isNotEmpty 
        ? "新闻内容：\n$articleContent\n\n【搜索引擎MCP返回结果】：\n$searchContext"
        : articleContent;

    try {
      final response = await _dio.post('/messages', data: {
        "model": "claude-3-sonnet-20240229",
        "max_tokens": 2048,
        "system": systemPrompt,
        "messages": [
          {"role": "user", "content": content}
        ]
      });
      return response.data['content'][0]['text'];
    } catch (e) {
      return "核查失败: $e";
    }
  }
}
