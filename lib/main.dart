import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox('settings');
  await Hive.openBox('preferences');
  await Hive.openBox('feed_cache');

  runApp(
    const ProviderScope(
      child: AttenLinkApp(),
    ),
  );
}
