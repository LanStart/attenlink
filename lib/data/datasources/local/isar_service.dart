import 'isar_entities.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Isar _isar;

  Isar get isar => _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [NewsArticleEntitySchema, VerificationResultEntitySchema],
      directory: dir.path,
    );
  }

  /// Full-text search for articles
  Future<List<NewsArticleEntity>> searchArticles(String query) async {
    return await _isar.newsArticleEntitys
        .where()
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .summaryContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .findAll();
  }

  /// Bulk upsert articles
  Future<void> upsertArticles(List<NewsArticleEntity> articles) async {
    await _isar.writeTxn(() async {
      await _isar.newsArticleEntitys.putAll(articles);
    });
  }

  /// Close Isar
  Future<void> close() async {
    await _isar.close();
  }
}
