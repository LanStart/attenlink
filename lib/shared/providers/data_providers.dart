import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/article_local_data_source.dart';
import '../../data/datasources/local/feed_source_local_data_source.dart';
import '../../data/datasources/local/ai_provider_local_data_source.dart';
import '../../data/datasources/local/verification_local_data_source.dart';
import '../../data/datasources/local/user_preferences_data_source.dart';
import '../../data/datasources/remote/feed_aggregator.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/feed_source_repository.dart';
import '../../data/repositories/ai_provider_repository.dart';
import '../../data/repositories/verification_repository.dart';

// ─── Data Sources ───

final articleLocalDataSourceProvider = Provider<ArticleLocalDataSource>((ref) {
  return ArticleLocalDataSource();
});

final feedSourceLocalDataSourceProvider = Provider<FeedSourceLocalDataSource>((ref) {
  return FeedSourceLocalDataSource();
});

final aiProviderLocalDataSourceProvider = Provider<AiProviderLocalDataSource>((ref) {
  return AiProviderLocalDataSource();
});

final verificationLocalDataSourceProvider = Provider<VerificationLocalDataSource>((ref) {
  return VerificationLocalDataSource();
});

final userPreferencesDataSourceProvider = Provider<UserPreferencesDataSource>((ref) {
  return UserPreferencesDataSource();
});

// ─── Repositories ───

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(
    localDataSource: ref.watch(articleLocalDataSourceProvider),
    verificationDataSource: ref.watch(verificationLocalDataSourceProvider),
  );
});

final feedSourceRepositoryProvider = Provider<FeedSourceRepository>((ref) {
  return FeedSourceRepository(
    localDataSource: ref.watch(feedSourceLocalDataSourceProvider),
  );
});

final aiProviderRepositoryProvider = Provider<AiProviderRepository>((ref) {
  return AiProviderRepository(
    localDataSource: ref.watch(aiProviderLocalDataSourceProvider),
  );
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(
    localDataSource: ref.watch(verificationLocalDataSourceProvider),
  );
});

// ─── Feed Aggregator ───

final feedAggregatorProvider = Provider<FeedAggregator>((ref) {
  return FeedAggregator(
    feedSourceRepo: ref.watch(feedSourceRepositoryProvider),
    articleRepo: ref.watch(articleRepositoryProvider),
  );
});

// ─── Async Data Providers ───

/// Provider for fetching all feed sources
final feedSourcesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(feedSourceRepositoryProvider);
  return repo.getAllFeedSources();
});

/// Provider for fetching enabled feed sources
final enabledFeedSourcesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(feedSourceRepositoryProvider);
  return repo.getEnabledFeedSources();
});

/// Provider for explore feed articles
final exploreFeedProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.getExploreFeed();
});

/// Provider for unacted articles (for swipe cards)
final unactedArticlesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.getUnactedArticles();
});

/// Provider for liked articles
final likedArticlesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.getLikedArticles();
});
