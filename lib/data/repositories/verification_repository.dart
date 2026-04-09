import '../datasources/local/verification_local_data_source.dart';
import '../models/verification_result.dart';

/// Repository for verification operations
class VerificationRepository {
  final VerificationLocalDataSource _localDataSource;

  VerificationRepository({
    required VerificationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  // ─── Read Operations ───

  /// Get a verification result by ID
  Future<VerificationResult?> getVerification(String id) =>
      _localDataSource.getVerification(id);

  /// Get verification result for a specific article
  Future<VerificationResult?> getVerificationByArticle(String articleId) =>
      _localDataSource.getVerificationByArticle(articleId);

  /// Get all verification results
  Future<List<VerificationResult>> getAllVerifications() =>
      _localDataSource.getAllVerifications();

  /// Get verifications that need follow-up
  Future<List<VerificationResult>> getVerificationsNeedingFollowUp() =>
      _localDataSource.getVerificationsNeedingFollowUp();

  /// Get verification count
  Future<int> getVerificationCount() =>
      _localDataSource.getVerificationCount();

  // ─── Write Operations ───

  /// Save a verification result
  Future<void> saveVerification(VerificationResult result) =>
      _localDataSource.saveVerification(result);

  /// Add a follow-up result to an existing verification
  Future<void> addFollowUp(String verificationId, FollowUpResult followUp) =>
      _localDataSource.addFollowUp(verificationId, followUp);

  /// Delete a verification result
  Future<void> deleteVerification(String id) =>
      _localDataSource.deleteVerification(id);

  /// Delete verification by article ID
  Future<void> deleteVerificationByArticle(String articleId) =>
      _localDataSource.deleteVerificationByArticle(articleId);

  // ─── Cleanup ───

  /// Delete all verifications
  Future<void> deleteAll() =>
      _localDataSource.deleteAllVerifications();
}
