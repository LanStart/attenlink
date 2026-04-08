import 'package:dio/dio.dart';
import '../ai_service.dart';

class GLMClient implements AIService {
  final String apiKey;
  final Dio _dio = Dio();
  
  GLMClient(this.apiKey, {String baseUrl = 'https://open.bigmodel.cn/api/paas/v4'}) {
    _dio.options.baseUrl = baseUrl.isNotEmpty ? baseUrl : 'https://open.bigmodel.cn/api/paas/v4';
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }
  
  @override
  Future<String> generateSummary(String text) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        "model": "glm-4",
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
  Future<String> factCheck(String articleContent) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        "model": "glm-4",
        "messages": [
          {"role": "system", "content": "你是一个事实核查助手，请分析以下新闻内容的真实性，并提供事实依据和总结。"},
          {"role": "user", "content": articleContent}
        ]
      });
      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      return "核查失败: $e";
    }
  }
}
