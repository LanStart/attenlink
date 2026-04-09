import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'data/datasources/local/feed_source_local_data_source.dart';
import 'data/datasources/local/ai_provider_local_data_source.dart';
import 'data/repositories/feed_source_repository.dart';
import 'data/repositories/ai_provider_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await Hive.initFlutter();

  // Open Hive boxes for app data
  await _initHiveBoxes();

  // Initialize default data
  await _initDefaults();

  runApp(
    const ProviderScope(
      child: AttenLinkApp(),
    ),
  );
}

/// Initialize all required Hive boxes
Future<void> _initHiveBoxes() async {
  final boxes = [
    'articles',
    'feed_sources',
    'ai_providers',
    'verifications',
    'settings',
    'preferences',
    'feed_cache',
  ];

  for (final boxName in boxes) {
    try {
      await Hive.openBox(boxName);
      logger.d('Opened Hive box: $boxName');
    } catch (e) {
      logger.e('Failed to open Hive box: $boxName', error: e);
    }
  }
}

/// Initialize default data if first launch
Future<void> _initDefaults() async {
  try {
    final prefsBox = Hive.box('preferences');
    final onboardingCompleted =
        prefsBox.get('onboarding_completed', defaultValue: false) as bool;

    if (!onboardingCompleted) {
      logger.i('First launch detected, initializing defaults...');

      // Initialize default feed sources
      final feedSourceRepo = FeedSourceRepository(
        localDataSource: FeedSourceLocalDataSource(),
      );
      await feedSourceRepo.initializeDefaults();

      // Initialize default AI providers
      final aiProviderRepo = AiProviderRepository(
        localDataSource: AiProviderLocalDataSource(),
      );
      await aiProviderRepo.initializeDefaults();

      // Mark onboarding as completed
      await prefsBox.put('onboarding_completed', true);
      logger.i('Default data initialized successfully');
    }
  } catch (e) {
    logger.e('Failed to initialize defaults', error: e);
  }
}
