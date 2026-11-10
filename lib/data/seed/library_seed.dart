import 'package:shared_preferences/shared_preferences.dart';

import '../models/library_item.dart';
import '../repositories/item_repository.dart';

const librarySeededKey = 'library_seeded';

Future<void> seedLibraryIfNeeded(
  SharedPreferences preferences,
  ItemRepository repository,
) async {
  if (preferences.getBool(librarySeededKey) == true) return;
  final existing = await repository.watchAll().first;
  if (existing.isEmpty) {
    for (final item in sampleLibrary()) {
      await repository.add(item);
    }
  }
  await preferences.setBool(librarySeededKey, true);
}

List<LibraryItem> sampleLibrary() {
  LibraryItem item({
    required String id,
    required ItemType type,
    required ItemSource source,
    required String text,
    required String languageCode,
    required DateTime createdAt,
    String? tag,
    int? page,
  }) {
    return LibraryItem(
      id: id,
      type: type,
      source: source,
      text: text,
      languageCode: languageCode,
      createdAt: createdAt,
      updatedAt: createdAt,
      recognitionStatus: RecognitionStatus.recognized,
      tag: tag,
      page: page,
    );
  }

  return [
    item(
      id: 'seed-01',
      type: ItemType.quote,
      source: ItemSource.scan,
      text: 'The quiet page is the one you return to.',
      languageCode: 'en',
      createdAt: DateTime.utc(2023, 1, 4),
      tag: 'Notebook',
      page: 12,
    ),
    item(
      id: 'seed-02',
      type: ItemType.quote,
      source: ItemSource.scan,
      text: 'Книга остаётся, когда день уже ушёл.',
      languageCode: 'ru',
      createdAt: DateTime.utc(2023, 3, 18),
      tag: 'Заметки',
      page: 40,
    ),
    item(
      id: 'seed-03',
      type: ItemType.note,
      source: ItemSource.manual,
      text: 'Ertaga shu gapni qayta oʻqish kerak.',
      languageCode: 'uz',
      createdAt: DateTime.utc(2023, 6, 2),
      tag: 'Daftar',
    ),
    item(
      id: 'seed-04',
      type: ItemType.voice,
      source: ItemSource.voice,
      text: 'Read the margin note before the next chapter.',
      languageCode: 'en',
      createdAt: DateTime.utc(2024, 1, 15),
      tag: 'Voice',
    ),
    item(
      id: 'seed-05',
      type: ItemType.note,
      source: ItemSource.manual,
      text: 'Ask why this sentence felt worth keeping.',
      languageCode: 'en',
      createdAt: DateTime.utc(2024, 4, 9),
    ),
    item(
      id: 'seed-06',
      type: ItemType.quote,
      source: ItemSource.scan,
      text: 'Light falls differently on a sentence you chose.',
      languageCode: 'en',
      createdAt: DateTime.utc(2024, 8, 21),
      tag: 'Poems',
      page: 7,
    ),
    item(
      id: 'seed-07',
      type: ItemType.voice,
      source: ItemSource.voice,
      text: 'Повторить абзац вслух вечером.',
      languageCode: 'ru',
      createdAt: DateTime.utc(2025, 1, 11),
    ),
    item(
      id: 'seed-08',
      type: ItemType.note,
      source: ItemSource.manual,
      text: 'Keep the tag only when the book matters.',
      languageCode: 'en',
      createdAt: DateTime.utc(2025, 3, 3),
      tag: 'Notebook',
    ),
    item(
      id: 'seed-09',
      type: ItemType.ai,
      source: ItemSource.manual,
      text: 'A saved sentence can be a question later.',
      languageCode: 'en',
      createdAt: DateTime.utc(2025, 6, 19),
    ),
    item(
      id: 'seed-10',
      type: ItemType.quote,
      source: ItemSource.scan,
      text: 'Gapni tanlaganingiz uni yorugʻ qiladi.',
      languageCode: 'uz',
      createdAt: DateTime.utc(2025, 9, 1),
      tag: 'Sheʼr',
      page: 3,
    ),
    item(
      id: 'seed-11',
      type: ItemType.voice,
      source: ItemSource.voice,
      text: 'Spoken on the tram, kept for the walk home.',
      languageCode: 'en',
      createdAt: DateTime.utc(2026, 1, 20),
    ),
    item(
      id: 'seed-12',
      type: ItemType.note,
      source: ItemSource.device,
      text: 'The pen stand-in left this sentence behind.',
      languageCode: 'en',
      createdAt: DateTime.utc(2026, 5, 2),
      tag: 'Device',
    ),
  ];
}
