import 'package:hive/hive.dart';

import '../../models/ai_provider_config.dart';
import '../../../core/utils/logger.dart';

/// Local data source for AI provider configurations using Hive
  static const _boxName = 'ai_providers';

  Box<String>? _box;

  /// Get or open the Hive box
  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  // ─── CRUD Operations ───

  /// Save an AI provider config
  Future<void> saveProvider(AiProviderConfig config) async {
    try {
      final box = await _getBox();
      await box.put(config.id, config.toJsonString());
      logger.d('Saved AI provider: ${config.id}');
    } catch (e) {
      logger.e('Failed to save AI provider: ${config.id}', error: e);
      rethrow;
    }
  }

  /// Save multiple AI provider configs
  Future<void> saveProviders(List<AiProviderConfig> configs) async {
    try {
      final box = await _getBox();
      final data = {for (final c in configs) c.id: c.toJsonString()};
      await box.putAll(data);
      logger.d('Saved ${configs.length} AI providers');
    } catch (e) {
      logger.e('Failed to save AI providers batch', error: e);
      rethrow;
    }
  }

  /// Get a single AI provider by ID
  Future<AiProviderConfig?> getProvider(String id) async {
    try {
      final box = await _getBox();
      final json = box.get(id);
      if (json == null) return null;
      return AiProviderConfig.fromJsonString(json);
    } catch (e) {
      logger.e('Failed to get AI provider: $id', error: e);
      return null;
    }
  }

  /// Get all AI providers
  Future<List<AiProviderConfig>> getAllProviders() async {
    try {
      final box = await _getBox();
      return box.values
          .map((json) {
            try {
              return AiProviderConfig.fromJsonString(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<AiProviderConfig>()
          .toList();
    } catch (e) {
      logger.e('Failed to get all AI providers', error: e);
      return [];
    }
  }

  /// Get enabled AI providers
  Future<List<AiProviderConfig>> getEnabledProviders() async {
    final providers = await getAllProviders();
    return providers.where((p) => p.isEnabled).toList();
  }

  /// Get the default AI provider
  Future<AiProviderConfig?> getDefaultProvider() async {
    final providers = await getAllProviders();
    try {
      return providers.firstWhere((p) => p.isDefault && p.isEnabled);
    } catch (_) {
      // Fallback to first enabled provider
      final enabled = providers.where((p) => p.isEnabled).toList();
      return enabled.isEmpty ? null : enabled.first;
    }
  }

  /// Get AI providers that support vision
  Future<List<AiProviderConfig>> getVisionProviders() async {
    final providers = await getEnabledProviders();
    return providers.where((p) => p.supportsVision).toList();
  }

  /// Get AI providers that support tool use
  Future<List<AiProviderConfig>> getToolUseProviders() async {
    final providers = await getEnabledProviders();
    return providers.where((p) => p.supportsToolUse).toList();
  }

  /// Delete an AI provider config
  Future<void> deleteProvider(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      logger.d('Deleted AI provider: $id');
    } catch (e) {
      logger.e('Failed to delete AI provider: $id', error: e);
      rethrow;
    }
  }

  /// Update provider API key
  Future<void> updateApiKey(String id, String apiKey) async {
    final provider = await getProvider(id);
    if (provider == null) return;
    await saveProvider(provider.copyWith(apiKey: apiKey));
  }

  /// Update provider enabled state
  Future<void> toggleProvider(String id, bool isEnabled) async {
    final provider = await getProvider(id);
    if (provider == null) return;
    await saveProvider(provider.copyWith(isEnabled: isEnabled));
  }

  /// Set a provider as default (unsets others)
  Future<void> setDefaultProvider(String id) async {
    final providers = await getAllProviders();
    for (final p in providers) {
      if (p.id == id) {
        await saveProvider(p.copyWith(isDefault: true));
      } else if (p.isDefault) {
        await saveProvider(p.copyWith(isDefault: false));
      }
    }
  }

  /// Record last usage timestamp
  Future<void> recordUsage(String id) async {
    final provider = await getProvider(id);
    if (provider == null) return;
    await saveProvider(provider.copyWith(lastUsedAt: DateTime.now()));
  }

  /// Initialize default AI provider configs if none exist
  Future<void> initializeDefaults() async {
    final existing = await getAllProviders();
    if (existing.isNotEmpty) return;

    final defaults = AiProviderType.values
        .map((type) => AiProviderConfig.createDefault(type))
        .toList();

    await saveProviders(defaults);
    logger.d('Initialized ${defaults.length} default AI providers');
  }

  /// Get provider count
  Future<int> getProviderCount() async {
    final box = await _getBox();
    return box.length;
  }

  /// Delete all providers
  Future<void> deleteAllProviders() async {
    try {
      final box = await _getBox();
      await box.clear();
      logger.d('Cleared all AI providers');
    } catch (e) {
      logger.e('Failed to clear AI providers', error: e);
      rethrow;
    }
  }

  /// Dispose
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
