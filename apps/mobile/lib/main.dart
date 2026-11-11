import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_providers.dart';
import 'app/hilight_app.dart';
import 'data/db/app_database.dart';
import 'data/repositories/drift_item_repository.dart';
import 'data/seed/library_seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final database = await AppDatabase.open();
  await seedLibraryIfNeeded(preferences, DriftItemRepository(database));
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const HiLightApp(),
    ),
  );
}
