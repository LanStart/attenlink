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
  })  : lastFetchedAt = lastFetchedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        extraConfig = extraConfig ?? const {};

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
    );
  }
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
}
