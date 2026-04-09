import 'dart:math' as math;

/// News weight calculation algorithm
/// Multi-dimensional scoring based on user behavior, verification status, and recency
class WeightAlgorithm {
  // Weight factors
  static const double _likeBonus = 2.5;         // Increased bonus for likes
  static const double _dislikePenalty = 0.2;     // Heavier penalty for dislikes
  static const double _verifiedBonus = 1.8;      // Bonus for factual verification
  static const double _disputedPenalty = 0.4;    // Penalty for disputed content
  static const double _readBonus = 1.2;
  static const double _longReadBonus = 1.5;      // Special bonus for deep reading
  static const double _tagMatchBonus = 1.4;
  static const double _sourceTrustBonus = 1.3;
  
  // Recency Decay: More aggressive decay for news
  static const double _recencyDecayFactor = 0.92; 
  static const int _recencyDecayHours = 1;       // Decay every hour

  /// Calculate the weight score for a news article
  static double calculate({
    double baseWeight = 1.0,
    bool isLiked = false,
    bool isDisliked = false,
    bool isRead = false,
    int readDurationSeconds = 0,
    bool isVerified = false,
    bool isDisputed = false,
    double tagMatchScore = 0.0,
    double sourceTrustScore = 0.5,
    required DateTime publishedAt,
    DateTime? now,
  }) {
    double weight = baseWeight;

    // 1. User Interaction Modifiers
    if (isLiked) weight *= _likeBonus;
    if (isDisliked) weight *= _dislikePenalty;
    if (isRead) {
      if (readDurationSeconds > 30) {
        weight *= _longReadBonus;
      } else {
        weight *= _readBonus;
      }
    }

    // 2. Verification Modifiers
    if (isVerified) weight *= _verifiedBonus;
    if (isDisputed) weight *= _disputedPenalty;

    // 3. Preference Matching
    weight *= 1.0 + (tagMatchScore * (_tagMatchBonus - 1.0));
    weight *= 1.0 + (sourceTrustScore * (_sourceTrustBonus - 1.0));

    // 4. Recency Decay (Exponential)
    final currentTime = now ?? DateTime.now();
    final minutesSincePublish = currentTime.difference(publishedAt).inMinutes;
    
    if (minutesSincePublish > 0) {
      // weight = weight * (decay_factor ^ (minutes / (decay_hours * 60)))
      final periods = minutesSincePublish / (_recencyDecayHours * 60);
      weight *= (identical(_recencyDecayFactor, 1.0) ? 1.0 : _power(_recencyDecayFactor, periods));
    }

    return weight;
  }

  /// Math helper for exponential decay
  static double _power(double base, double exponent) {
    import 'dart:math' as math;
    return math.pow(base, exponent).toDouble();
  }

  /// Calculate tag match score between article tags and user preference tags
  static double calculateTagMatchScore(
    List<String> articleTags,
    Map<String, double> userPreferenceWeights,
  ) {
    if (articleTags.isEmpty || userPreferenceWeights.isEmpty) return 0.5;

    double totalScore = 0.0;
    int count = 0;
    
    for (final tag in articleTags) {
      if (userPreferenceWeights.containsKey(tag)) {
        totalScore += userPreferenceWeights[tag]!;
        count++;
      }
    }

    if (count == 0) return 0.5;
    return totalScore / count;
  }
}
