import 'package:dio/dio.dart';
import '../ai_service.dart';

class OpenAIClient implements AIService {
  final String apiKey;
  final Dio _dio = Dio();
  
  OpenAIClient(this.apiKey, {String baseUrl = 'https://api.openai.com/v1'}) {
    _dio.options.baseUrl = baseUrl.isNotEmpty ? baseUrl : 'https://api.openai.com/v1';
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }
  
  @override
  Future<String> generateSummary(String text) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "你是一个新闻总结助手，请用简短的中文总结以下内容。"},
          {"role": "user", "content": text}
        ]
      });
      return response.data['choices'][0]['message']['content'];
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
      final response = await _dio.post('/chat/completions', data: {
        "model": "gpt-4",
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": content}
        ]
      });
      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      return "核查失败: $e";
    }
  }
}
