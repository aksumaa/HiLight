import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/library_item.dart';

part 'app_database.g.dart';

class Items extends Table {
  TextColumn get id => text()();

  TextColumn get type => text()();

  TextColumn get source => text()();

  TextColumn get body => text().named('text')();

  TextColumn get tag => text().nullable()();

  IntColumn get page => integer().nullable()();

  TextColumn get audioPath => text().nullable()();

  TextColumn get imagePath => text().nullable()();

  TextColumn get language => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  TextColumn get recognitionStatus => text()();

  TextColumn get highlightColor => text().withDefault(const Constant('gold'))();

  TextColumn get note => text().nullable()();

  BoolColumn get favorite => boolean().withDefault(const Constant(false))();

  TextColumn get chapter => text().nullable()();

  TextColumn get bookId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Books extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get author => text().nullable()();

  TextColumn get coverUrl => text().nullable()();

  IntColumn get totalPages => integer().nullable()();

  TextColumn get isbn => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Words extends Table {
  TextColumn get id => text()();

  TextColumn get word => text()();

  TextColumn get sourceLanguage => text()();

  TextColumn get targetLanguage => text()();

  TextColumn get translation => text().withDefault(const Constant(''))();

  TextColumn get definition => text().withDefault(const Constant(''))();

  TextColumn get example => text().withDefault(const Constant(''))();

  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();

  TextColumn get sourceSentence => text().withDefault(const Constant(''))();

  TextColumn get sourceItemId => text().nullable()();

  TextColumn get tags => text().withDefault(const Constant(''))();

  TextColumn get mastery => text().withDefault(const Constant('newWord'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ReviewCards extends Table {
  TextColumn get id => text()();

  TextColumn get kind => text()();

  TextColumn get wordId => text().nullable()();

  TextColumn get itemId => text().nullable()();

  TextColumn get prompt => text()();

  TextColumn get answer => text()();

  RealColumn get ease => real().withDefault(const Constant(2.5))();

  IntColumn get intervalDays => integer().withDefault(const Constant(0))();

  IntColumn get repetitions => integer().withDefault(const Constant(0))();

  DateTimeColumn get dueAt => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ReviewLogs extends Table {
  TextColumn get id => text()();

  TextColumn get cardId => text()();

  IntColumn get rating => integer()();

  IntColumn get intervalDays => integer()();

  DateTimeColumn get reviewedAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get itemId => text()();

  TextColumn get operation => text()();

  TextColumn get entityType => text().withDefault(const Constant('item'))();

  DateTimeColumn get enqueuedAt => dateTime()();
}

@DriftDatabase(tables: [Items, OutboxEntries, Books, Words, ReviewCards, ReviewLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(items, items.updatedAt);
        await migrator.addColumn(items, items.deletedAt);
        await migrator.addColumn(items, items.dirty);
        await migrator.createTable(outboxEntries);
      }
      if (from < 3) {
        await migrator.addColumn(items, items.highlightColor);
        await migrator.addColumn(items, items.note);
        await migrator.addColumn(items, items.favorite);
        await migrator.addColumn(items, items.chapter);
        await migrator.addColumn(items, items.bookId);
        await migrator.addColumn(outboxEntries, outboxEntries.entityType);
        await migrator.createTable(books);
        await migrator.createTable(words);
        await migrator.createTable(reviewCards);
        await migrator.createTable(reviewLogs);
      }
    },
  );

  static Future<AppDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'hilight.sqlite'));
    return AppDatabase(NativeDatabase(file));
  }

  @override
  int get schemaVersion => 3;
}

LibraryItem libraryItemFromRow(Item row) {
  return LibraryItem(
    id: row.id,
    type: ItemType.values.byName(row.type),
    source: ItemSource.values.byName(row.source),
    text: row.body,
    tag: row.tag,
    page: row.page,
    audioPath: row.audioPath,
    imagePath: row.imagePath,
    highlightColor: HighlightColor.values.byName(row.highlightColor),
    note: row.note,
    favorite: row.favorite,
    chapter: row.chapter,
    bookId: row.bookId,
    languageCode: row.language,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    dirty: row.dirty,
    recognitionStatus: RecognitionStatus.values.byName(row.recognitionStatus),
  );
}

ItemsCompanion companionFor(LibraryItem item) {
  return ItemsCompanion.insert(
    id: item.id,
    type: item.type.name,
    source: item.source.name,
    body: item.text,
    tag: Value(item.tag),
    page: Value(item.page),
    audioPath: Value(item.audioPath),
    imagePath: Value(item.imagePath),
    highlightColor: Value(item.highlightColor.name),
    note: Value(item.note),
    favorite: Value(item.favorite),
    chapter: Value(item.chapter),
    bookId: Value(item.bookId),
    language: item.languageCode,
    createdAt: item.createdAt,
    updatedAt: Value(item.modifiedAt),
    deletedAt: Value(item.deletedAt),
    dirty: Value(item.dirty),
    recognitionStatus: item.recognitionStatus.name,
  );
}
