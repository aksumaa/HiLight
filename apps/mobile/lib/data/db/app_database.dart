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

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get itemId => text()();

  TextColumn get operation => text()();

  DateTimeColumn get enqueuedAt => dateTime()();
}

@DriftDatabase(tables: [Items, OutboxEntries])
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
    },
  );

  static Future<AppDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'hilight.sqlite'));
    return AppDatabase(NativeDatabase(file));
  }

  @override
  int get schemaVersion => 2;
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
    language: item.languageCode,
    createdAt: item.createdAt,
    updatedAt: Value(item.modifiedAt),
    deletedAt: Value(item.deletedAt),
    dirty: Value(item.dirty),
    recognitionStatus: item.recognitionStatus.name,
  );
}
