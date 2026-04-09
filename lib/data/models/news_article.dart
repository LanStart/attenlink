import 'dart:convert';

/// News article model - the core data entity
/// Supports JSON serialization for Hive storage
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String url;
  final String imageUrl;
  final String sourceId;
  final String sourceName;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final List<String> tags;
  final String category;

  // User interaction
  final UserAction userAction;
  final DateTime? actionAt;

  // Verification
  final VerificationStatus verificationStatus;
  final String? verificationId;

  // Weight & tracking
  final double weight;
  final bool isRead;
  final int readDurationSeconds;
  final DateTime? nextFollowUpAt;

  const NewsArticle({
    required this.id,
    required this.title,
    this.summary = '',
    this.content = '',
    required this.url,
    this.imageUrl = '',
    required this.sourceId,
    required this.sourceName,
    required this.publishedAt,
    required this.fetchedAt,
    this.tags = const [],
    this.category = '',
    this.userAction = UserAction.none,
    this.actionAt,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationId,
    this.weight = 1.0,
    this.isRead = false,
    this.readDurationSeconds = 0,
    this.nextFollowUpAt,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? url,
    String? imageUrl,
    String? sourceId,
    String? sourceName,
    DateTime? publishedAt,
    DateTime? fetchedAt,
    List<String>? tags,
    String? category,
    UserAction? userAction,
    DateTime? actionAt,
    VerificationStatus? verificationStatus,
    String? verificationId,
    double? weight,
    bool? isRead,
    int? readDurationSeconds,
    DateTime? nextFollowUpAt,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      publishedAt: publishedAt ?? this.publishedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      userAction: userAction ?? this.userAction,
      actionAt: actionAt ?? this.actionAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationId: verificationId ?? this.verificationId,
      weight: weight ?? this.weight,
      isRead: isRead ?? this.isRead,
      readDurationSeconds: readDurationSeconds ?? this.readDurationSeconds,
      nextFollowUpAt: nextFollowUpAt ?? this.nextFollowUpAt,
    );
  }

  /// Whether the article has been acted upon (liked/disliked)
  bool get hasAction => userAction != UserAction.none;

  /// Whether the article needs follow-up verification
  bool get needsFollowUp =>
      userAction == UserAction.liked &&
      nextFollowUpAt != null &&
      DateTime.now().isAfter(nextFollowUpAt!);

  // ─── JSON Serialization ───

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      sourceId: json['sourceId'] as String,
      sourceName: json['sourceName'] as String,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(json['publishedAt'] as int),
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(json['fetchedAt'] as int),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String? ?? '',
      userAction: UserAction.values[json['userAction'] as int? ?? 0],
      actionAt: json['actionAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['actionAt'] as int)
          : null,
      verificationStatus:
          VerificationStatus.values[json['verificationStatus'] as int? ?? 0],
      verificationId: json['verificationId'] as String?,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      isRead: json['isRead'] as bool? ?? false,
      readDurationSeconds: json['readDurationSeconds'] as int? ?? 0,
      nextFollowUpAt: json['nextFollowUpAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextFollowUpAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
      'fetchedAt': fetchedAt.millisecondsSinceEpoch,
      'tags': tags,
      'category': category,
      'userAction': userAction.index,
      'actionAt': actionAt?.millisecondsSinceEpoch,
      'verificationStatus': verificationStatus.index,
      'verificationId': verificationId,
      'weight': weight,
      'isRead': isRead,
      'readDurationSeconds': readDurationSeconds,
      'nextFollowUpAt': nextFollowUpAt?.millisecondsSinceEpoch,
    };
  }

  /// Serialize to JSON string for Hive storage
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize from JSON string
  factory NewsArticle.fromJsonString(String jsonString) {
    return NewsArticle.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() => 'NewsArticle(id: $id, title: $title, status: $verificationStatus)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// User action on a news article
enum UserAction {
  none,
  liked,
  disliked;

  String get label {
    switch (this) {
      case UserAction.none:
        return '';
      case UserAction.liked:
        return '喜欢';
      case UserAction.disliked:
        return '不感兴趣';
    }
  }
}

/// Verification status of a news article
enum VerificationStatus {
  pending,    // Not yet verified
  verifying,  // Currently being verified
  verified,   // Verified as factual
  disputed,   // Found to be disputed/inaccurate
  outdated;   // Information is outdated

  String get label {
    switch (this) {
      case VerificationStatus.pending:
        return '待查证';
      case VerificationStatus.verifying:
        return '查证中';
      case VerificationStatus.verified:
        return '已查证';
      case VerificationStatus.disputed:
        return '有争议';
      case VerificationStatus.outdated:
        return '已过时';
    }
  }

  /// Color indicator for verification status
  int get colorValue {
    switch (this) {
      case VerificationStatus.pending:
        return 0xFFFBBC04; // Yellow
      case VerificationStatus.verifying:
        return 0xFF1A73E8; // Blue
      case VerificationStatus.verified:
        return 0xFF34A853; // Green
      case VerificationStatus.disputed:
        return 0xFFEA4335; // Red
      case VerificationStatus.outdated:
        return 0xFF9AA0A6; // Grey
    }
  }
}
