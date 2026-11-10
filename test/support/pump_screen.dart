import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/app/app_providers.dart';
import 'package:hilight/core/l10n/app_localizations.dart';
import 'package:hilight/core/theme/hilight_theme.dart';
import 'package:hilight/data/models/library_item.dart';
import 'package:hilight/data/repositories/item_repository.dart';
import 'package:hilight/features/profile/application/settings_controller.dart';
import 'package:hilight/features/profile/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryItemRepository implements ItemRepository {
  MemoryItemRepository(this._items);

  final List<LibraryItem> _items;

  @override
  Stream<List<LibraryItem>> watchAll() async* {
    yield List<LibraryItem>.unmodifiable(_items);
  }

  @override
  Future<LibraryItem> add(LibraryItem item) async => item;

  @override
  Future<void> applyRemote(LibraryItem item) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<LibraryItem?> findAny(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<OutboxJob>> pendingJobs() async => const [];

  @override
  Future<void> removeJob(int id) async {}

  @override
  Future<LibraryItem> update(LibraryItem item) async => item;
}

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<LibraryItem> items = const [],
  Map<String, Object> prefs = const {},
}) async {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({
    'onboarding_complete': true,
    'gate_passed': true,
    'app_locale': 'en',
    ...prefs,
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        itemRepositoryProvider.overrideWithValue(MemoryItemRepository(items)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(settingsProvider);
          final accent = accentColor(settings.accent);
          return MaterialApp(
            locale: Locale(settings.localeCode),
            theme: HilightTheme.light(accent: accent),
            darkTheme: HilightTheme.dark(accent: accent),
            themeMode: settings.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontScale),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: screen,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LibraryItem sampleItem({
  required String id,
  required ItemType type,
  required String text,
  String? tag,
}) {
  return LibraryItem(
    id: id,
    type: type,
    source: type == ItemType.voice ? ItemSource.voice : ItemSource.scan,
    text: text,
    tag: tag,
    languageCode: 'en',
    createdAt: DateTime.utc(2024, 1, 1),
    recognitionStatus: RecognitionStatus.recognized,
  );
}
