import 'package:hive/hive.dart';

import '../../models/verification_result.dart';
import '../../../core/utils/logger.dart';

/// Local data source for verification results using Hive
class VerificationLocalDataSource {
  static const _boxName = 'verifications';

  Box<String>? _box;

  /// Get or open the Hive box
  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  // ─── CRUD Operations ───

  /// Save a verification result
  Future<void> saveVerification(VerificationResult result) async {
    try {
      final box = await _getBox();
      await box.put(result.id, result.toJsonString());
      logger.d('Saved verification: ${result.id}');
    } catch (e) {
      logger.e('Failed to save verification: ${result.id}', error: e);
      rethrow;
    }
  }

  /// Get a verification result by ID
  Future<VerificationResult?> getVerification(String id) async {
    try {
      final box = await _getBox();
      final json = box.get(id);
      if (json == null) return null;
      return VerificationResult.fromJsonString(json);
    } catch (e) {
      logger.e('Failed to get verification: $id', error: e);
      return null;
    }
  }

  /// Get verification result for a specific article
  Future<VerificationResult?> getVerificationByArticle(String articleId) async {
    try {
      final all = await getAllVerifications();
      return all.where((v) => v.articleId == articleId).firstOrNull;
    } catch (e) {
      logger.e('Failed to get verification for article: $articleId', error: e);
      return null;
    }
  }

  /// Get all verification results
  Future<List<VerificationResult>> getAllVerifications() async {
    try {
      final box = await _getBox();
      return box.values
          .map((json) {
            try {
              return VerificationResult.fromJsonString(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<VerificationResult>()
          .toList();
    } catch (e) {
      logger.e('Failed to get all verifications', error: e);
      return [];
    }
  }

  /// Get verifications that need follow-up
  Future<List<VerificationResult>> getVerificationsNeedingFollowUp() async {
    final now = DateTime.now();
    final all = await getAllVerifications();
    return all.where((v) => v.needsFollowUpCheck(now)).toList();
  }

  /// Add a follow-up result to an existing verification
  Future<void> addFollowUp(String verificationId, FollowUpResult followUp) async {
    final verification = await getVerification(verificationId);
    if (verification == null) return;
    final updated = verification.copyWith(
      followUps: [...verification.followUps, followUp],
    );
    await saveVerification(updated);
  }

  /// Delete a verification result
  Future<void> deleteVerification(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      logger.d('Deleted verification: $id');
    } catch (e) {
      logger.e('Failed to delete verification: $id', error: e);
      rethrow;
    }
  }

  /// Delete verification by article ID
  Future<void> deleteVerificationByArticle(String articleId) async {
    final verification = await getVerificationByArticle(articleId);
    if (verification != null) {
      await deleteVerification(verification.id);
    }
  }

  /// Get verification count
  Future<int> getVerificationCount() async {
    final box = await _getBox();
    return box.length;
  }

  /// Delete all verifications
  Future<void> deleteAllVerifications() async {
    try {
      final box = await _getBox();
      await box.clear();
      logger.d('Cleared all verifications');
    } catch (e) {
      logger.e('Failed to clear verifications', error: e);
      rethrow;
    }
  }

  /// Dispose
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
