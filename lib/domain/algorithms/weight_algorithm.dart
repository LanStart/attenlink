/// News weight calculation algorithm
/// Multi-dimensional scoring based on user behavior, verification status, and recency
class WeightAlgorithm {
  // Weight factors
  static const double _likeBonus = 2.0;
  static const double _dislikePenalty = 0.3;
  static const double _verifiedBonus = 1.5;
  static const double _disputedPenalty = 0.5;
  static const double _readBonus = 1.1;
  static const double _tagMatchBonus = 1.3;
  static const double _sourceTrustBonus = 1.2;
  static const double _recencyDecayFactor = 0.95;
  static const int _recencyDecayHours = 2;

  /// Calculate the weight score for a news article
  ///
  /// [baseWeight] - starting weight (default 1.0)
  /// [isLiked] - user liked this article
  /// [isDisliked] - user disliked this article
  /// [isRead] - user has read this article
  /// [isVerified] - article has been verified as factual
  /// [isDisputed] - article has been disputed
  /// [tagMatchScore] - how well tags match user preferences (0.0-1.0)
  /// [sourceTrustScore] - trust score of the source (0.0-1.0)
  /// [publishedAt] - when the article was published
  /// [now] - current time (for testing)
  static double calculate({
    double baseWeight = 1.0,
    bool isLiked = false,
    bool isDisliked = false,
    bool isRead = false,
    bool isVerified = false,
    bool isDisputed = false,
    double tagMatchScore = 0.0,
    double sourceTrustScore = 0.5,
    required DateTime publishedAt,
    DateTime? now,
  }) {
    double weight = baseWeight;

    // User interaction modifiers
    if (isLiked) weight *= _likeBonus;
    if (isDisliked) weight *= _dislikePenalty;
    if (isRead) weight *= _readBonus;

    // Verification modifiers
    if (isVerified) weight *= _verifiedBonus;
    if (isDisputed) weight *= _disputedPenalty;

    // Preference matching
    weight *= 1.0 + (tagMatchScore * (_tagMatchBonus - 1.0));
    weight *= 1.0 + (sourceTrustScore * (_sourceTrustBonus - 1.0));

    // Recency decay
    final currentTime = now ?? DateTime.now();
    final hoursSincePublish = currentTime.difference(publishedAt).inHours;
    final decayFactor = _hoursToDecayFactor(hoursSincePublish);
    weight *= decayFactor;

    return weight;
  }

  /// Convert hours since publish to a decay factor
  static double _hoursToDecayFactor(int hours) {
    if (hours <= 0) return 1.0;
    // Exponential decay: each _recencyDecayHours, weight decays by _recencyDecayFactor
    final periods = hours / _recencyDecayHours;
    return _recencyDecayFactor * periods;
  }

  /// Calculate tag match score between article tags and user preference tags
  static double calculateTagMatchScore(
    List<String> articleTags,
    List<String> userPreferenceTags,
  ) {
    if (articleTags.isEmpty || userPreferenceTags.isEmpty) return 0.0;

    int matches = 0;
    for (final tag in articleTags) {
      if (userPreferenceTags.contains(tag)) {
        matches++;
      }
    }

    return matches / articleTags.length;
  }

  /// Update user preference tag weights based on interaction
  static Map<String, double> updateTagPreferences(
    Map<String, double> currentPreferences,
    List<String> articleTags, {
    required bool isLiked,
    required bool isDisliked,
  }) {
    final updated = Map<String, double>.from(currentPreferences);

    for (final tag in articleTags) {
      final current = updated[tag] ?? 1.0;
      if (isLiked) {
        updated[tag] = current * 1.2; // Boost liked tags
      } else if (isDisliked) {
        updated[tag] = current * 0.8; // Reduce disliked tags
      }
    }

    return updated;
  }
}
