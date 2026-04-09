import '../datasources/local/ai_provider_local_data_source.dart';
import '../models/ai_provider_config.dart';

/// Repository for AI provider operations
class AiProviderRepository {
  final AiProviderLocalDataSource _localDataSource;

  AiProviderRepository({
    required AiProviderLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  // ─── Read Operations ───

  /// Get a single AI provider by ID
  Future<AiProviderConfig?> getProvider(String id) =>
      _localDataSource.getProvider(id);

  /// Get all AI providers
  Future<List<AiProviderConfig>> getAllProviders() =>
      _localDataSource.getAllProviders();

  /// Get enabled AI providers
  Future<List<AiProviderConfig>> getEnabledProviders() =>
      _localDataSource.getEnabledProviders();

  /// Get the default AI provider
  Future<AiProviderConfig?> getDefaultProvider() =>
      _localDataSource.getDefaultProvider();

  /// Get AI providers that support vision
  Future<List<AiProviderConfig>> getVisionProviders() =>
      _localDataSource.getVisionProviders();

  /// Get AI providers that support tool use
  Future<List<AiProviderConfig>> getToolUseProviders() =>
      _localDataSource.getToolUseProviders();

  /// Get provider count
  Future<int> getProviderCount() =>
      _localDataSource.getProviderCount();

  // ─── Write Operations ───

  /// Save an AI provider config
  Future<void> saveProvider(AiProviderConfig config) =>
      _localDataSource.saveProvider(config);

  /// Delete an AI provider config
  Future<void> deleteProvider(String id) =>
      _localDataSource.deleteProvider(id);

  /// Update provider API key
  Future<void> updateApiKey(String id, String apiKey) =>
      _localDataSource.updateApiKey(id, apiKey);

  /// Toggle provider enabled/disabled
  Future<void> toggleProvider(String id, bool isEnabled) =>
      _localDataSource.toggleProvider(id, isEnabled);

  /// Set a provider as default (unsets others)
  Future<void> setDefaultProvider(String id) =>
      _localDataSource.setDefaultProvider(id);

  /// Record last usage timestamp
  Future<void> recordUsage(String id) =>
      _localDataSource.recordUsage(id);

  // ─── Initialization ───

  /// Initialize default AI provider configs if none exist
  Future<void> initializeDefaults() =>
      _localDataSource.initializeDefaults();

  // ─── Cleanup ───

  /// Delete all providers
  Future<void> deleteAll() =>
      _localDataSource.deleteAllProviders();
}
