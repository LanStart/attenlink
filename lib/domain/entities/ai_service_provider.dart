import '../../data/models/verification_result.dart';

/// AI message model
class ChatMessage {
  final String role; // system, user, assistant
  final String content;
  final List<String>? imageUrls;

  const ChatMessage({
    required this.role,
    required this.content,
    this.imageUrls,
  });
}

/// MCP Tool definition
class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const McpTool({
    required this.name,
    required this.description,
    required this.parameters,
  });
}

/// MCP Tool call result
class McpToolResult {
  final String toolName;
  final Map<String, dynamic> result;
  final bool success;

  const McpToolResult({
    required this.toolName,
    required this.result,
    required this.success,
  });
}

/// Abstract AI service provider interface
/// All AI service providers must implement this interface
abstract class AiServiceProvider {
  /// Unique provider identifier
  String get id;

  /// Display name
  String get displayName;

  /// Provider type
  String get type;

  /// Whether this provider supports vision/image analysis
  bool get supportsVision;

  /// Whether this provider supports tool use / function calling
  bool get supportsToolUse;

  /// Send a chat completion request
  /// [messages] - conversation messages
  /// [tools] - optional MCP tools to make available
  Future<String> chat(
    List<ChatMessage> messages, {
    List<McpTool>? tools,
  });

  /// Generate text embeddings for semantic search
  Future<List<double>> embedText(String text);

  /// Analyze an image with a text prompt
  /// Returns null if the provider doesn't support vision
  Future<String?> analyzeImage(String imagePath, String prompt);

  /// Verify a news article using AI
  /// Returns a verification result with cross-references
  Future<VerificationResult> verifyArticle({
    required String articleTitle,
    required String articleContent,
    required String articleUrl,
  });

  /// Dispose any resources
  void dispose() {}
}
