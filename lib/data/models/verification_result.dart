/// Verification result for a news article
class VerificationResult {
  final String id;
  final String articleId;
  final Verdict verdict;
  final String aiSummary;
  final List<SourceReference> crossReferences;
  final DateTime verifiedAt;
  final double confidenceScore;
  final String? providerId;
  final List<FollowUpResult> followUps;

  const VerificationResult({
    required this.id,
    required this.articleId,
    required this.verdict,
    required this.aiSummary,
    this.crossReferences = const [],
    required this.verifiedAt,
    required this.confidenceScore,
    this.providerId,
    this.followUps = const [],
  });
}

/// Verification verdict
enum Verdict {
  verified,   // Confirmed factual
  disputed,   // Found to be disputed
  unverified, // Cannot be verified
  outdated,   // Information is outdated
}

/// Cross-reference source
class SourceReference {
  final String title;
  final String url;
  final String sourceName;
  final DateTime? publishedAt;
  final Verdict alignment; // How this source aligns with the original article

  const SourceReference({
    required this.title,
    required this.url,
    required this.sourceName,
    this.publishedAt,
    this.alignment = Verdict.verified,
  });
}

/// Follow-up verification result
class FollowUpResult {
  final String id;
  final DateTime checkedAt;
  final Verdict verdict;
  final String summary;
  final List<SourceReference> newSources;

  const FollowUpResult({
    required this.id,
    required this.checkedAt,
    required this.verdict,
    required this.summary,
    this.newSources = const [],
  });
}
