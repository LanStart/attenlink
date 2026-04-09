import '../datasources/local/article_local_data_source.dart';
import '../datasources/local/verification_local_data_source.dart';
import '../models/news_article.dart';
import '../models/verification_result.dart';

/// Repository for news article operations
/// Coordinates between local data source and (future) remote data source
class ArticleRepository {
  final ArticleLocalDataSource _localDataSource;
  final VerificationLocalDataSource _verificationDataSource;

  ArticleRepository({
    required ArticleLocalDataSource localDataSource,
    required VerificationLocalDataSource verificationDataSource,
  })  : _localDataSource = localDataSource,
        _verificationDataSource = verificationDataSource;

  // ─── Read Operations ───

  /// Get a single article by ID
  Future<NewsArticle?> getArticle(String id) =>
      _localDataSource.getArticle(id);

  /// Get all articles
  Future<List<NewsArticle>> getAllArticles() =>
      _localDataSource.getAllArticles();

  /// Get articles sorted by weight (for explore feed)
  Future<List<NewsArticle>> getExploreFeed() =>
      _localDataSource.getArticlesSortedByWeight();

  /// Get unacted articles (for explore swipe cards)
  Future<List<NewsArticle>> getUnactedArticles() =>
      _localDataSource.getUnactedArticles();

  /// Get liked articles
  Future<List<NewsArticle>> getLikedArticles() =>
      _localDataSource.getLikedArticles();

  /// Get articles by source
  Future<List<NewsArticle>> getArticlesBySource(String sourceId) =>
      _localDataSource.getArticlesBySource(sourceId);

  /// Search articles by keyword
  Future<List<NewsArticle>> searchArticles(String query) =>
      _localDataSource.searchArticles(query);

  /// Get articles needing follow-up verification
  Future<List<NewsArticle>> getArticlesNeedingFollowUp() =>
      _localDataSource.getArticlesNeedingFollowUp();

  /// Get article count
  Future<int> getArticleCount() =>
      _localDataSource.getArticleCount();

  // ─── Write Operations ───

  /// Save a single article
  Future<void> saveArticle(NewsArticle article) =>
      _localDataSource.saveArticle(article);

  /// Save multiple articles (batch)
  Future<void> saveArticles(List<NewsArticle> articles) =>
      _localDataSource.saveArticles(articles);

  /// Delete an article
  Future<void> deleteArticle(String id) =>
      _localDataSource.deleteArticle(id);

  // ─── User Actions ───

  /// Like an article and trigger verification
  Future<void> likeArticle(String id) async {
    await _localDataSource.updateArticleAction(id, UserAction.liked);
    // Update verification status to verifying
    await _localDataSource.updateVerificationStatus(
      id,
      VerificationStatus.verifying,
      null,
    );
  }

  /// Dislike an article
  Future<void> dislikeArticle(String id) =>
      _localDataSource.updateArticleAction(id, UserAction.disliked);

  /// Mark article as read
  Future<void> markAsRead(String id, {int readDurationSeconds = 0}) =>
      _localDataSource.markAsRead(id, readDurationSeconds: readDurationSeconds);

  // ─── Verification ───

  /// Get verification result for an article
  Future<VerificationResult?> getVerificationForArticle(String articleId) =>
      _verificationDataSource.getVerificationByArticle(articleId);

  /// Save verification result and update article status
  Future<void> saveVerificationResult(
    VerificationResult result,
  ) async {
    await _verificationDataSource.saveVerification(result);
    // Update article verification status based on verdict
    final status = _verdictToStatus(result.effectiveVerdict);
    await _localDataSource.updateVerificationStatus(
      result.articleId,
      status,
      result.id,
    );
  }

  /// Get articles with their verification results
  Future<List<ArticleWithVerification>> getArticlesWithVerification() async {
    final articles = await getAllArticles();
    final results = <ArticleWithVerification>[];

    for (final article in articles) {
      VerificationResult? verification;
      if (article.verificationId != null) {
        verification = await _verificationDataSource
            .getVerification(article.verificationId!);
      }
      results.add(ArticleWithVerification(
        article: article,
        verification: verification,
      ));
    }

    return results;
  }

  // ─── Weight Updates ───

  /// Update article weight
  Future<void> updateWeight(String id, double weight) =>
      _localDataSource.updateArticleWeight(id, weight);

  // ─── Cleanup ───

  /// Delete all articles and their verifications
  Future<void> deleteAll() async {
    await _localDataSource.deleteAllArticles();
    await _verificationDataSource.deleteAllVerifications();
  }

  // ─── Helpers ───

  VerificationStatus _verdictToStatus(Verdict verdict) {
    switch (verdict) {
      case Verdict.verified:
        return VerificationStatus.verified;
      case Verdict.disputed:
        return VerificationStatus.disputed;
      case Verdict.unverified:
        return VerificationStatus.pending;
      case Verdict.outdated:
        return VerificationStatus.outdated;
    }
  }
}

/// Article with its associated verification result
class ArticleWithVerification {
  final NewsArticle article;
  final VerificationResult? verification;

  const ArticleWithVerification({
    required this.article,
    this.verification,
  });
}
