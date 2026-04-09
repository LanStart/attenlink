import 'dart:convert';

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
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  AiProviderConfig({
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
    Map<String, String>? extraConfig,
    DateTime? createdAt,
    this.lastUsedAt,
  })  : extraConfig = extraConfig ?? const {},
        createdAt = createdAt ?? DateTime.now();

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
    DateTime? createdAt,
    DateTime? lastUsedAt,
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
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Whether this provider is properly configured (has API key and base URL)
  bool get isConfigured => apiKey.isNotEmpty && baseUrl.isNotEmpty;

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

  /// Get the default base URL for this provider type
  static String getDefaultBaseUrl(AiProviderType type) {
    switch (type) {
      case AiProviderType.openai:
        return 'https://api.openai.com/v1';
      case AiProviderType.claude:
        return 'https://api.anthropic.com/v1';
      case AiProviderType.gemini:
        return 'https://generativelanguage.googleapis.com/v1beta';
      case AiProviderType.kimi:
        return 'https://api.moonshot.cn/v1';
      case AiProviderType.glm:
        return 'https://open.bigmodel.cn/api/paas/v4';
    }
  }

  /// Get the default models for this provider type
  static List<String> getDefaultModels(AiProviderType type) {
    switch (type) {
      case AiProviderType.openai:
        return ['gpt-4o', 'gpt-4o-mini', 'o1', 'o3-mini'];
      case AiProviderType.claude:
        return ['claude-3-5-sonnet-20241022', 'claude-3-opus-20240229'];
      case AiProviderType.gemini:
        return ['gemini-2.0-flash', 'gemini-1.5-pro'];
      case AiProviderType.kimi:
        return ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'];
      case AiProviderType.glm:
        return ['glm-4', 'glm-4v', 'glm-4-flash'];
    }
  }

  /// Create a default config for a provider type
  static AiProviderConfig createDefault(AiProviderType type) {
    final models = getDefaultModels(type);
    return AiProviderConfig(
      id: type.name,
      type: type,
      displayName: type.label,
      baseUrl: getDefaultBaseUrl(type),
      model: models.first,
    );
  }

  // ─── JSON Serialization ───

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) {
    final extraConfigRaw = json['extraConfig'];
    Map<String, String> extraConfig = const {};
    if (extraConfigRaw is Map) {
      extraConfig = extraConfigRaw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    return AiProviderConfig(
      id: json['id'] as String,
      type: AiProviderType.values[json['type'] as int],
      displayName: json['displayName'] as String,
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      model: json['model'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] as int? ?? 4096,
      extraConfig: extraConfig,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUsedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'displayName': displayName,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'model': model,
      'isEnabled': isEnabled,
      'isDefault': isDefault,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'extraConfig': extraConfig,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUsedAt': lastUsedAt?.millisecondsSinceEpoch,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AiProviderConfig.fromJsonString(String jsonString) {
    return AiProviderConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() =>
      'AiProviderConfig(id: $id, type: $type, enabled: $isEnabled, configured: $isConfigured)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiProviderConfig && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
