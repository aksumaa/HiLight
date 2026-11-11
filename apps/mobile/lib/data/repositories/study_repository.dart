import 'package:drift/drift.dart';

import '../../features/capture/domain/capture_file_store.dart';
import '../../features/study/domain/scheduler.dart';
import '../../features/study/domain/vocab_word.dart';
import '../db/app_database.dart';

class StudyRepository {
  StudyRepository(this._database);

  final AppDatabase _database;

  Stream<List<VocabWord>> watchWords() {
    final query = _database.select(_database.words)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    return query.watch().map((rows) => rows.map(_word).toList());
  }

  Stream<List<StudyCard>> watchCards() {
    final query = _database.select(_database.reviewCards)
      ..where((row) => row.deletedAt.isNull());
    return query.watch().map((rows) => rows.map(_card).toList());
  }

  Stream<List<DateTime>> watchReviewDays() {
    final query = _database.select(_database.reviewLogs)
      ..where((row) => row.deletedAt.isNull());
    return query.watch().map((rows) => rows.map((row) => row.reviewedAt).toList());
  }

  Future<VocabWord> saveWord(VocabWord word) async {
    final now = DateTime.now().toUtc();
    final stored = word.copyWith(dirty: true, updatedAt: now);
    await _database.into(_database.words).insert(_wordCompanion(stored), mode: InsertMode.insertOrReplace);
    await _enqueue(stored.id, 'word', 'upsert');
    final existing = await (_database.select(_database.reviewCards)
          ..where((row) => row.wordId.equals(stored.id) & row.deletedAt.isNull()))
        .getSingleOrNull();
    if (existing == null) {
      await _insertCard(
        kind: 'word',
        prompt: stored.word,
        answer: stored.translation.isEmpty ? stored.definition : stored.translation,
        wordId: stored.id,
        itemId: stored.sourceItemId,
      );
    }
    return stored;
  }

  Future<void> setMastery(String id, WordMastery mastery) async {
    final row = await (_database.select(_database.words)..where((word) => word.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    final next = _word(row).copyWith(mastery: mastery, dirty: true, updatedAt: DateTime.now().toUtc());
    await _database.into(_database.words).insert(_wordCompanion(next), mode: InsertMode.insertOrReplace);
    await _enqueue(id, 'word', 'upsert');
  }

  Future<VocabWord?> softDelete(String id) async {
    final row = await (_database.select(_database.words)..where((word) => word.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final now = DateTime.now().toUtc();
    final next = _word(row).copyWith(deletedAt: now, dirty: true, updatedAt: now);
    await _database.into(_database.words).insert(_wordCompanion(next), mode: InsertMode.insertOrReplace);
    await _enqueue(id, 'word', 'delete');
    return _word(row);
  }

  Future<void> restore(VocabWord word) async {
    final restored = word.copyWith(clearDeleted: true, dirty: true, updatedAt: DateTime.now().toUtc());
    await _database.into(_database.words).insert(_wordCompanion(restored), mode: InsertMode.insertOrReplace);
    await _enqueue(word.id, 'word', 'upsert');
  }

  Future<void> ensureHighlightCards({
    required String itemId,
    required String text,
  }) async {
    final existing = await (_database.select(_database.reviewCards)
          ..where((row) => row.itemId.equals(itemId) & row.deletedAt.isNull()))
        .get();
    final kinds = existing.map((row) => row.kind).toSet();
    final cloze = _cloze(text);
    if (!kinds.contains('quote')) {
      await _insertCard(kind: 'quote', prompt: text, answer: text, itemId: itemId);
    }
    if (!kinds.contains('cloze') && cloze != null) {
      await _insertCard(kind: 'cloze', prompt: cloze.$1, answer: cloze.$2, itemId: itemId);
    }
  }

  Future<void> applyReview(StudyCard card, int quality) async {
    const scheduler = Sm2Scheduler();
    final now = DateTime.now().toUtc();
    final next = scheduler.review(card.progress, quality, now);
    await _database.into(_database.reviewCards).insert(
      ReviewCardsCompanion(
        id: Value(card.id),
        kind: Value(card.kind),
        wordId: Value(card.wordId),
        itemId: Value(card.itemId),
        prompt: Value(card.prompt),
        answer: Value(card.answer),
        ease: Value(next.progress.ease),
        intervalDays: Value(next.progress.intervalDays),
        repetitions: Value(next.progress.repetitions),
        dueAt: Value(next.due),
        createdAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
      mode: InsertMode.insertOrReplace,
    );
    final logId = _id();
    await _database.into(_database.reviewLogs).insert(
      ReviewLogsCompanion.insert(
        id: logId,
        cardId: card.id,
        rating: quality,
        intervalDays: next.progress.intervalDays,
        reviewedAt: now,
        updatedAt: now,
      ),
    );
    await _enqueue(card.id, 'card', 'upsert');
    await _enqueue(logId, 'review_log', 'upsert');
  }

  Future<void> recordQuiz({
    required String prompt,
    required String answer,
    required int quality,
  }) async {
    final rows = await (_database.select(_database.reviewCards)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final needle = answer.toLowerCase();
    ReviewCard? match;
    for (final row in rows) {
      if (row.answer.toLowerCase() == needle || row.prompt.toLowerCase() == prompt.toLowerCase()) {
        match = row;
        break;
      }
    }
    final card = match == null
        ? await _loadCard(
            await _insertCard(kind: 'quiz', prompt: prompt, answer: answer),
          )
        : _card(match);
    if (card == null) return;
    await applyReview(card, quality);
  }

  Future<StudyCard?> _loadCard(String id) async {
    final row = await (_database.select(_database.reviewCards)..where((card) => card.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _card(row);
  }

  Future<String> _insertCard({
    required String kind,
    required String prompt,
    required String answer,
    String? wordId,
    String? itemId,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _id();
    await _database.into(_database.reviewCards).insert(
      ReviewCardsCompanion.insert(
        id: id,
        kind: kind,
        prompt: prompt,
        answer: answer,
        wordId: Value(wordId),
        itemId: Value(itemId),
        dueAt: now,
        createdAt: now,
        updatedAt: now,
        dirty: const Value(true),
      ),
    );
    await _enqueue(id, 'card', 'upsert');
    return id;
  }

  String _id() => createCaptureId();

  Future<void> _enqueue(String id, String entity, String operation) {
    return _database.into(_database.outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        itemId: id,
        operation: operation,
        entityType: Value(entity),
        enqueuedAt: DateTime.now().toUtc(),
      ),
    );
  }

  WordsCompanion _wordCompanion(VocabWord word) {
    return WordsCompanion.insert(
      id: word.id,
      word: word.word,
      sourceLanguage: word.sourceLanguage,
      targetLanguage: word.targetLanguage,
      translation: Value(word.translation),
      definition: Value(word.definition),
      example: Value(word.example),
      partOfSpeech: Value(word.partOfSpeech),
      sourceSentence: Value(word.sourceSentence),
      sourceItemId: Value(word.sourceItemId),
      tags: Value(word.tags),
      mastery: Value(word.mastery.name),
      createdAt: word.createdAt,
      updatedAt: word.updatedAt,
      deletedAt: Value(word.deletedAt),
      dirty: Value(word.dirty),
    );
  }

  VocabWord _word(Word row) {
    return VocabWord(
      id: row.id,
      word: row.word,
      sourceLanguage: row.sourceLanguage,
      targetLanguage: row.targetLanguage,
      translation: row.translation,
      definition: row.definition,
      example: row.example,
      partOfSpeech: row.partOfSpeech,
      sourceSentence: row.sourceSentence,
      sourceItemId: row.sourceItemId,
      tags: row.tags,
      mastery: WordMastery.values.byName(row.mastery),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      dirty: row.dirty,
    );
  }

  StudyCard _card(ReviewCard row) {
    return StudyCard(
      id: row.id,
      kind: row.kind,
      prompt: row.prompt,
      answer: row.answer,
      wordId: row.wordId,
      itemId: row.itemId,
      progress: CardProgress(
        ease: row.ease,
        intervalDays: row.intervalDays,
        repetitions: row.repetitions,
      ),
      dueAt: row.dueAt,
    );
  }

  Future<Map<String, dynamic>?> wordPayload(String id) async {
    final row = await (_database.select(_database.words)..where((word) => word.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final word = _word(row);
    return {
      'word': word.word,
      'source_language': word.sourceLanguage,
      'target_language': word.targetLanguage,
      'translation': word.translation,
      'definition': word.definition,
      'example': word.example,
      'part_of_speech': word.partOfSpeech,
      'source_sentence': word.sourceSentence,
      'source_item_id': word.sourceItemId,
      'tags': word.tags,
      'mastery': word.mastery.name,
      'updated_at': word.updatedAt.toUtc().toIso8601String(),
      'deleted_at': word.deletedAt?.toUtc().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>?> cardPayload(String id) async {
    final row = await (_database.select(_database.reviewCards)..where((card) => card.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return {
      'kind': row.kind,
      'word_id': row.wordId,
      'item_id': row.itemId,
      'prompt': row.prompt,
      'answer': row.answer,
      'ease': row.ease,
      'interval_days': row.intervalDays,
      'repetitions': row.repetitions,
      'due_at': row.dueAt.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>?> logPayload(String id) async {
    final row = await (_database.select(_database.reviewLogs)..where((log) => log.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return {
      'card_id': row.cardId,
      'rating': row.rating,
      'interval_days': row.intervalDays,
      'reviewed_at': row.reviewedAt.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  Future<void> applyWord(Map<String, dynamic> json) async {
    final updatedAt = DateTime.parse(json['updated_at'] as String);
    final existing = await (_database.select(_database.words)..where((row) => row.id.equals(json['id'] as String)))
        .getSingleOrNull();
    if (existing != null && existing.updatedAt.isAfter(updatedAt)) return;
    final word = VocabWord(
      id: json['id'] as String,
      word: json['word'] as String,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      translation: json['translation'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      example: json['example'] as String? ?? '',
      partOfSpeech: json['part_of_speech'] as String? ?? '',
      sourceSentence: json['source_sentence'] as String? ?? '',
      sourceItemId: json['source_item_id'] as String?,
      tags: json['tags'] as String? ?? '',
      mastery: WordMastery.values.byName(json['mastery'] as String? ?? 'newWord'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
    );
    await _database.into(_database.words).insert(_wordCompanion(word), mode: InsertMode.insertOrReplace);
  }

  Future<void> applyCard(Map<String, dynamic> json) async {
    final updatedAt = DateTime.parse(json['updated_at'] as String);
    final existing = await (
      _database.select(_database.reviewCards)..where((row) => row.id.equals(json['id'] as String))
    ).getSingleOrNull();
    if (existing != null && existing.updatedAt.isAfter(updatedAt)) return;
    await _database.into(_database.reviewCards).insert(
      ReviewCardsCompanion.insert(
        id: json['id'] as String,
        kind: json['kind'] as String,
        prompt: json['prompt'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        wordId: Value(json['word_id'] as String?),
        itemId: Value(json['item_id'] as String?),
        ease: Value((json['ease'] as num?)?.toDouble() ?? 2.5),
        intervalDays: Value(json['interval_days'] as int? ?? 0),
        repetitions: Value(json['repetitions'] as int? ?? 0),
        dueAt: DateTime.parse(json['due_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        deletedAt: Value(json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String)),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> applyLog(Map<String, dynamic> json) async {
    final updatedAt = DateTime.parse(json['updated_at'] as String);
    final existing = await (
      _database.select(_database.reviewLogs)..where((row) => row.id.equals(json['id'] as String))
    ).getSingleOrNull();
    if (existing != null && existing.updatedAt.isAfter(updatedAt)) return;
    await _database.into(_database.reviewLogs).insert(
      ReviewLogsCompanion.insert(
        id: json['id'] as String,
        cardId: json['card_id'] as String,
        rating: json['rating'] as int,
        intervalDays: json['interval_days'] as int? ?? 0,
        reviewedAt: DateTime.parse(json['reviewed_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        deletedAt: Value(json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String)),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  (String, String)? _cloze(String text) {
    final match = RegExp("[A-Za-z][A-Za-z'-]{4,}").firstMatch(text);
    if (match == null) return null;
    final word = match.group(0)!;
    return (text.replaceFirst(word, '_____'), word);
  }
}
