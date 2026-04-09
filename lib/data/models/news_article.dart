/// News article model - the core data entity
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

  // Weight
  final double weight;
  final bool isRead;

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
    );
  }
}

/// User action on a news article
enum UserAction {
  none,
  liked,
  disliked,
}

/// Verification status of a news article
enum VerificationStatus {
  pending,    // Not yet verified
  verifying,  // Currently being verified
  verified,   // Verified as factual
  disputed,   // Found to be disputed/inaccurate
  outdated,   // Information is outdated
}
