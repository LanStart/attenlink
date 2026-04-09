import 'package:hive/hive.dart';

import '../../models/news_article.dart';
import '../../../core/utils/logger.dart';

/// Local data source for news articles using Hive
class ArticleLocalDataSource {
  static const _boxName = 'articles';

  Box<String>? _box;

  /// Get or open the Hive box
  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  // ─── CRUD Operations ───

  /// Save a single article
  Future<void> saveArticle(NewsArticle article) async {
    try {
      final box = await _getBox();
      await box.put(article.id, article.toJsonString());
      logger.d('Saved article: ${article.id}');
    } catch (e) {
      logger.e('Failed to save article: ${article.id}', error: e);
      rethrow;
    }
  }

  /// Save multiple articles (batch)
  Future<void> saveArticles(List<NewsArticle> articles) async {
    try {
      final box = await _getBox();
      final Map<String, String> data = {
        for (final article in articles) article.id: article.toJsonString(),
      };
      await box.putAll(data);
      logger.d('Saved ${articles.length} articles');
    } catch (e) {
      logger.e('Failed to save articles batch', error: e);
      rethrow;
    }
  }

  /// Get a single article by ID
  Future<NewsArticle?> getArticle(String id) async {
    try {
      final box = await _getBox();
      final json = box.get(id);
      if (json == null) return null;
      return NewsArticle.fromJsonString(json);
    } catch (e) {
      logger.e('Failed to get article: $id', error: e);
      return null;
    }
  }

  /// Get all articles
  Future<List<NewsArticle>> getAllArticles() async {
    try {
      final box = await _getBox();
      return box.values
          .map((json) {
            try {
              return NewsArticle.fromJsonString(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<NewsArticle>()
          .toList();
    } catch (e) {
      logger.e('Failed to get all articles', error: e);
      return [];
    }
  }

  /// Get articles by source ID
  Future<List<NewsArticle>> getArticlesBySource(String sourceId) async {
    final articles = await getAllArticles();
    return articles.where((a) => a.sourceId == sourceId).toList();
  }

  /// Get articles by verification status
  Future<List<NewsArticle>> getArticlesByVerificationStatus(
    VerificationStatus status,
  ) async {
    final articles = await getAllArticles();
    return articles.where((a) => a.verificationStatus == status).toList();
  }

  /// Get articles that need follow-up verification
  Future<List<NewsArticle>> getArticlesNeedingFollowUp() async {
    final now = DateTime.now();
    final articles = await getAllArticles();
    return articles.where((a) => a.needsFollowUp).toList()
      ..where((a) => a.nextFollowUpAt!.isBefore(now)).toList();
  }

  /// Get articles sorted by weight (descending)
  Future<List<NewsArticle>> getArticlesSortedByWeight() async {
    final articles = await getAllArticles();
    articles.sort((a, b) => b.weight.compareTo(a.weight));
    return articles;
  }

  /// Get articles that haven't been acted upon (for explore feed)
  Future<List<NewsArticle>> getUnactedArticles() async {
    final articles = await getAllArticles();
    return articles.where((a) => !a.hasAction).toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));
  }

  /// Get liked articles
  Future<List<NewsArticle>> getLikedArticles() async {
    final articles = await getAllArticles();
    return articles
        .where((a) => a.userAction == UserAction.liked)
        .toList()
      ..sort((a, b) => b.actionAt!.compareTo(a.actionAt!));
  }

  /// Search articles by keyword
  Future<List<NewsArticle>> searchArticles(String query) async {
    if (query.trim().isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final articles = await getAllArticles();
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
          article.summary.toLowerCase().contains(lowerQuery) ||
          article.content.toLowerCase().contains(lowerQuery) ||
          article.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  /// Delete an article
  Future<void> deleteArticle(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      logger.d('Deleted article: $id');
    } catch (e) {
      logger.e('Failed to delete article: $id', error: e);
      rethrow;
    }
  }

  /// Update user action on an article
  Future<void> updateArticleAction(
    String id,
    UserAction action,
  ) async {
    final article = await getArticle(id);
    if (article == null) return;
    final updated = article.copyWith(
      userAction: action,
      actionAt: DateTime.now(),
      // If liked, schedule follow-up verification for 24h later
      nextFollowUpAt: action == UserAction.liked
          ? DateTime.now().add(const Duration(hours: 24))
          : article.nextFollowUpAt,
    );
    await saveArticle(updated);
  }

  /// Update article verification status
  Future<void> updateVerificationStatus(
    String id,
    VerificationStatus status,
    String? verificationId,
  ) async {
    final article = await getArticle(id);
    if (article == null) return;
    final updated = article.copyWith(
      verificationStatus: status,
      verificationId: verificationId ?? article.verificationId,
    );
    await saveArticle(updated);
  }

  /// Update article weight
  Future<void> updateArticleWeight(String id, double weight) async {
    final article = await getArticle(id);
    if (article == null) return;
    await saveArticle(article.copyWith(weight: weight));
  }

  /// Mark article as read
  Future<void> markAsRead(String id, {int readDurationSeconds = 0}) async {
    final article = await getArticle(id);
    if (article == null) return;
    await saveArticle(article.copyWith(
      isRead: true,
      readDurationSeconds: article.readDurationSeconds + readDurationSeconds,
    ));
  }

  /// Delete all articles
  Future<void> deleteAllArticles() async {
    try {
      final box = await _getBox();
      await box.clear();
      logger.d('Cleared all articles');
    } catch (e) {
      logger.e('Failed to clear articles', error: e);
      rethrow;
    }
  }

  /// Get article count
  Future<int> getArticleCount() async {
    final box = await _getBox();
    return box.length;
  }

  /// Get articles count by source
  Future<Map<String, int>> getArticleCountBySource() async {
    final articles = await getAllArticles();
    final countMap = <String, int>{};
    for (final article in articles) {
      countMap[article.sourceId] = (countMap[article.sourceId] ?? 0) + 1;
    }
    return countMap;
  }

  /// Dispose
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
