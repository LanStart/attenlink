abstract class AIService {
  Future<String> generateSummary(String text);
  Future<String> factCheck(String articleContent, {String? searchContext});
}
