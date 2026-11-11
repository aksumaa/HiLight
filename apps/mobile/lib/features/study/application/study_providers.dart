import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../books/domain/book_metadata_service.dart';
import '../../books/domain/shelf_book.dart';
import '../../profile/application/settings_controller.dart';
import '../domain/scheduler.dart';
import '../domain/vocab_word.dart';
import '../domain/word_lookup_service.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DriftBookRepository(ref.watch(appDatabaseProvider));
});

final booksProvider = StreamProvider<List<ShelfBook>>((ref) {
  return ref.watch(bookRepositoryProvider).watchAll();
});

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepository(ref.watch(appDatabaseProvider));
});

final vocabProvider = StreamProvider<List<VocabWord>>((ref) {
  return ref.watch(studyRepositoryProvider).watchWords();
});

final studyCardsProvider = StreamProvider<List<StudyCard>>((ref) {
  return ref.watch(studyRepositoryProvider).watchCards();
});

final reviewDaysProvider = StreamProvider<List<DateTime>>((ref) {
  return ref.watch(studyRepositoryProvider).watchReviewDays();
});

final reviewDueCountProvider = Provider<int>((ref) {
  final cards = ref.watch(studyCardsProvider).value ?? const <StudyCard>[];
  final settings = ref.watch(settingsProvider);
  return reviewQueue(
    cards,
    DateTime.now(),
    reviewLimit: settings.dailyReviewLimit,
    newLimit: settings.dailyNewLimit,
  ).length;
});

final wordOfDayProvider = Provider<String?>((ref) {
  final words = ref.watch(vocabProvider).value ?? const <VocabWord>[];
  if (words.isEmpty) return null;
  final day = DateTime.now().difference(DateTime(2026)).inDays;
  return words[day.abs() % words.length].word;
});

final bookMetadataProvider = Provider<BookMetadataService>((ref) {
  const fake = bool.fromEnvironment('USE_FAKE_BOOKS');
  if (fake) return const FakeBookMetadataService();
  return OpenLibraryMetadataService();
});

final wordLookupProvider = Provider<WordLookupService>((ref) {
  const fake = bool.fromEnvironment('USE_FAKE_DICTIONARY');
  if (fake) return const FakeWordLookupService();
  final api = ref.watch(apiClientProvider);
  return RemoteWordLookupService(dio: api.dio, bearer: api.bearer);
});
