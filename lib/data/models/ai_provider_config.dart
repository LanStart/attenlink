/// AI service provider configuration
class AiProviderConfig {
  final String id;
  final AiProviderType type;
  final String displayName;
  final String apiKey;
  final String baseUrl;
  final String model;
  final bool isEnabled;
  final bool isDefault;
  final double temperature;
  final int maxTokens;
  final Map<String, String> extraConfig;

  const AiProviderConfig({
    required this.id,
    required this.type,
    required this.displayName,
    this.apiKey = '',
    this.baseUrl = '',
    this.model = '',
    this.isEnabled = false,
    this.isDefault = false,
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.extraConfig = const {},
  });

  AiProviderConfig copyWith({
    String? id,
    AiProviderType? type,
    String? displayName,
    String? apiKey,
    String? baseUrl,
    String? model,
    bool? isEnabled,
    bool? isDefault,
    double? temperature,
    int? maxTokens,
    Map<String, String>? extraConfig,
  }) {
    return AiProviderConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      isEnabled: isEnabled ?? this.isEnabled,
      isDefault: isDefault ?? this.isDefault,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      extraConfig: extraConfig ?? this.extraConfig,
    );
  }

  /// Whether this provider supports vision/image analysis
  bool get supportsVision {
    switch (type) {
      case AiProviderType.openai:
        return model.contains('vision') || model.contains('gpt-4o');
      case AiProviderType.claude:
        return model.contains('claude-3');
      case AiProviderType.gemini:
        return true;
      case AiProviderType.kimi:
        return true;
      case AiProviderType.glm:
        return model.contains('glm-4v');
    }
  }

  /// Whether this provider supports tool use / function calling
  bool get supportsToolUse {
    switch (type) {
      case AiProviderType.openai:
      case AiProviderType.claude:
      case AiProviderType.gemini:
        return true;
      case AiProviderType.kimi:
      case AiProviderType.glm:
        return false;
    }
  }
}

/// Supported AI provider types
enum AiProviderType {
  openai,
  claude,
  gemini,
  kimi,
  glm;

  String get label {
    switch (this) {
      case AiProviderType.openai:
        return 'OpenAI';
      case AiProviderType.claude:
        return 'Claude';
      case AiProviderType.gemini:
        return 'Gemini';
      case AiProviderType.kimi:
        return 'Kimi';
      case AiProviderType.glm:
        return 'GLM';
    }
  }
}
