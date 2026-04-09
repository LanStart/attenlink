import 'dart:convert';

/// Feed source configuration model
class FeedSourceConfig {
  final String id;
  final String name;
  final String url;
  final FeedSourceType type;
  final bool isEnabled;
  final int fetchIntervalMinutes;
  final DateTime lastFetchedAt;
  final String category;
  final Map<String, String> extraConfig;
  final DateTime createdAt;

  FeedSourceConfig({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.isEnabled = true,
    this.fetchIntervalMinutes = 30,
    DateTime? lastFetchedAt,
    this.category = 'general',
    Map<String, String>? extraConfig,
    DateTime? createdAt,
  })  : lastFetchedAt = lastFetchedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        extraConfig = extraConfig ?? const {},
        createdAt = createdAt ?? DateTime.now();

  FeedSourceConfig copyWith({
    String? id,
    String? name,
    String? url,
    FeedSourceType? type,
    bool? isEnabled,
    int? fetchIntervalMinutes,
    DateTime? lastFetchedAt,
    String? category,
    Map<String, String>? extraConfig,
    DateTime? createdAt,
  }) {
    return FeedSourceConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      fetchIntervalMinutes: fetchIntervalMinutes ?? this.fetchIntervalMinutes,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      category: category ?? this.category,
      extraConfig: extraConfig ?? this.extraConfig,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether this source is due for a refresh
  bool get needsRefresh {
    if (!isEnabled) return false;
    final elapsed = DateTime.now().difference(lastFetchedAt);
    return elapsed.inMinutes >= fetchIntervalMinutes;
  }

  // ─── JSON Serialization ───

  factory FeedSourceConfig.fromJson(Map<String, dynamic> json) {
    return FeedSourceConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: FeedSourceType.values[json['type'] as int],
      isEnabled: json['isEnabled'] as bool? ?? true,
      fetchIntervalMinutes: json['fetchIntervalMinutes'] as int? ?? 30,
      lastFetchedAt: json['lastFetchedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastFetchedAt'] as int)
          : null,
      category: json['category'] as String? ?? 'general',
      extraConfig: (json['extraConfig'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type.index,
      'isEnabled': isEnabled,
      'fetchIntervalMinutes': fetchIntervalMinutes,
      'lastFetchedAt': lastFetchedAt.millisecondsSinceEpoch,
      'category': category,
      'extraConfig': extraConfig,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String toJsonString() => jsonEncode(toJson);

  factory FeedSourceConfig.fromJsonString(String jsonString) {
    return FeedSourceConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() =>
      'FeedSourceConfig(id: $id, name: $name, type: $type, enabled: $isEnabled)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedSourceConfig && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Supported feed source types
enum FeedSourceType {
  rss,
  atom,
  jsonFeed,
  hackerNews,
  reddit,
  custom;

  String get label {
    switch (this) {
      case FeedSourceType.rss:
        return 'RSS';
      case FeedSourceType.atom:
        return 'Atom';
      case FeedSourceType.jsonFeed:
        return 'JSON Feed';
      case FeedSourceType.hackerNews:
        return 'HackerNews';
      case FeedSourceType.reddit:
        return 'Reddit';
      case FeedSourceType.custom:
        return '自定义';
    }
  }

  /// Auto-detect feed type from URL
  static FeedSourceType detectFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('hacker-news.firebaseio.com') || lower.contains('hnrss.org')) {
      return FeedSourceType.hackerNews;
    }
    if (lower.contains('reddit.com') && lower.endsWith('.json')) {
      return FeedSourceType.reddit;
    }
    if (lower.endsWith('.json') || lower.contains('jsonfeed')) {
      return FeedSourceType.jsonFeed;
    }
    if (lower.contains('/feed') || lower.contains('/rss')) {
      return FeedSourceType.rss;
    }
    if (lower.contains('/atom') || lower.contains('atom.xml')) {
      return FeedSourceType.atom;
    }
    return FeedSourceType.rss; // Default to RSS
  }
}
