import 'dart:convert';

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

  /// The latest follow-up result, or null if none
  FollowUpResult? get latestFollowUp =>
      followUps.isEmpty ? null : followUps.last;

  /// The current effective verdict (follow-up may update it)
  Verdict get effectiveVerdict {
    if (followUps.isEmpty) return verdict;
    return followUps.last.verdict;
  }

  /// Whether this verification needs a follow-up check
  bool needsFollowUpCheck(DateTime now) {
    if (effectiveVerdict == Verdict.verified) {
      // Verified articles should be re-checked every 24h
      final lastCheck = followUps.isEmpty ? verifiedAt : followUps.last.checkedAt;
      return now.difference(lastCheck).inHours >= 24;
    }
    return false;
  }

  VerificationResult copyWith({
    String? id,
    String? articleId,
    Verdict? verdict,
    String? aiSummary,
    List<SourceReference>? crossReferences,
    DateTime? verifiedAt,
    double? confidenceScore,
    String? providerId,
    List<FollowUpResult>? followUps,
  }) {
    return VerificationResult(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      verdict: verdict ?? this.verdict,
      aiSummary: aiSummary ?? this.aiSummary,
      crossReferences: crossReferences ?? this.crossReferences,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      providerId: providerId ?? this.providerId,
      followUps: followUps ?? this.followUps,
    );
  }

  // ─── JSON Serialization ───

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      id: json['id'] as String,
      articleId: json['articleId'] as String,
      verdict: Verdict.values[json['verdict'] as int],
      aiSummary: json['aiSummary'] as String,
      crossReferences: (json['crossReferences'] as List<dynamic>)
          .map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      verifiedAt: DateTime.fromMillisecondsSinceEpoch(json['verifiedAt'] as int),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      providerId: json['providerId'] as String?,
      followUps: (json['followUps'] as List<dynamic>)
          .map((e) => FollowUpResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'verdict': verdict.index,
      'aiSummary': aiSummary,
      'crossReferences': crossReferences.map((e) => e.toJson()).toList(),
      'verifiedAt': verifiedAt.millisecondsSinceEpoch,
      'confidenceScore': confidenceScore,
      'providerId': providerId,
      'followUps': followUps.map((e) => e.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory VerificationResult.fromJsonString(String jsonString) {
    return VerificationResult.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}

/// Verification verdict
enum Verdict {
  verified,   // Confirmed factual
  disputed,   // Found to be disputed
  unverified, // Cannot be verified
  outdated;   // Information is outdated

  String get label {
    switch (this) {
      case Verdict.verified:
        return '已查证属实';
      case Verdict.disputed:
        return '存在争议';
      case Verdict.unverified:
        return '无法查证';
      case Verdict.outdated:
        return '信息过时';
    }
  }
}

/// Cross-reference source
class SourceReference {
  final String title;
  final String url;
  final String sourceName;
  final DateTime? publishedAt;
  final Verdict alignment;

  const SourceReference({
    required this.title,
    required this.url,
    required this.sourceName,
    this.publishedAt,
    this.alignment = Verdict.verified,
  });

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    return SourceReference(
      title: json['title'] as String,
      url: json['url'] as String,
      sourceName: json['sourceName'] as String,
      publishedAt: json['publishedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['publishedAt'] as int)
          : null,
      alignment: Verdict.values[json['alignment'] as int? ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'sourceName': sourceName,
      'publishedAt': publishedAt?.millisecondsSinceEpoch,
      'alignment': alignment.index,
    };
  }
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

  factory FollowUpResult.fromJson(Map<String, dynamic> json) {
    return FollowUpResult(
      id: json['id'] as String,
      checkedAt: DateTime.fromMillisecondsSinceEpoch(json['checkedAt'] as int),
      verdict: Verdict.values[json['verdict'] as int],
      summary: json['summary'] as String,
      newSources: (json['newSources'] as List<dynamic>)
          .map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkedAt': checkedAt.millisecondsSinceEpoch,
      'verdict': verdict.index,
      'summary': summary,
      'newSources': newSources.map((e) => e.toJson()).toList(),
    };
  }
}
