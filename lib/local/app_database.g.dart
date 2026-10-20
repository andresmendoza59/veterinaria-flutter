// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AnimalNotesTable extends AnimalNotes
    with TableInfo<$AnimalNotesTable, AnimalNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animalIdMeta = const VerificationMeta(
    'animalId',
  );
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
    'animal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    animalId,
    note,
    updatedAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimalNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('animal_id')) {
      context.handle(
        _animalIdMeta,
        animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animalId};
  @override
  AnimalNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalNoteRow(
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $AnimalNotesTable createAlias(String alias) {
    return $AnimalNotesTable(attachedDatabase, alias);
  }
}

class AnimalNoteRow extends DataClass implements Insertable<AnimalNoteRow> {
  final String animalId;
  final String note;
  final DateTime updatedAt;
  final bool pendingSync;
  const AnimalNoteRow({
    required this.animalId,
    required this.note,
    required this.updatedAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['animal_id'] = Variable<String>(animalId);
    map['note'] = Variable<String>(note);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  AnimalNotesCompanion toCompanion(bool nullToAbsent) {
    return AnimalNotesCompanion(
      animalId: Value(animalId),
      note: Value(note),
      updatedAt: Value(updatedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory AnimalNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalNoteRow(
      animalId: serializer.fromJson<String>(json['animalId']),
      note: serializer.fromJson<String>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animalId': serializer.toJson<String>(animalId),
      'note': serializer.toJson<String>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  AnimalNoteRow copyWith({
    String? animalId,
    String? note,
    DateTime? updatedAt,
    bool? pendingSync,
  }) => AnimalNoteRow(
    animalId: animalId ?? this.animalId,
    note: note ?? this.note,
    updatedAt: updatedAt ?? this.updatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  AnimalNoteRow copyWithCompanion(AnimalNotesCompanion data) {
    return AnimalNoteRow(
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalNoteRow(')
          ..write('animalId: $animalId, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(animalId, note, updatedAt, pendingSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalNoteRow &&
          other.animalId == this.animalId &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt &&
          other.pendingSync == this.pendingSync);
}

class AnimalNotesCompanion extends UpdateCompanion<AnimalNoteRow> {
  final Value<String> animalId;
  final Value<String> note;
  final Value<DateTime> updatedAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const AnimalNotesCompanion({
    this.animalId = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalNotesCompanion.insert({
    required String animalId,
    required String note,
    required DateTime updatedAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : animalId = Value(animalId),
       note = Value(note),
       updatedAt = Value(updatedAt);
  static Insertable<AnimalNoteRow> custom({
    Expression<String>? animalId,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animalId != null) 'animal_id': animalId,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalNotesCompanion copyWith({
    Value<String>? animalId,
    Value<String>? note,
    Value<DateTime>? updatedAt,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return AnimalNotesCompanion(
      animalId: animalId ?? this.animalId,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalNotesCompanion(')
          ..write('animalId: $animalId, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AnimalNotesTable animalNotes = $AnimalNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [animalNotes];
}

typedef $$AnimalNotesTableCreateCompanionBuilder =
    AnimalNotesCompanion Function({
      required String animalId,
      required String note,
      required DateTime updatedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$AnimalNotesTableUpdateCompanionBuilder =
    AnimalNotesCompanion Function({
      Value<String> animalId,
      Value<String> note,
      Value<DateTime> updatedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$AnimalNotesTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalNotesTable> {
  $$AnimalNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimalNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalNotesTable> {
  $$AnimalNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimalNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalNotesTable> {
  $$AnimalNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$AnimalNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimalNotesTable,
          AnimalNoteRow,
          $$AnimalNotesTableFilterComposer,
          $$AnimalNotesTableOrderingComposer,
          $$AnimalNotesTableAnnotationComposer,
          $$AnimalNotesTableCreateCompanionBuilder,
          $$AnimalNotesTableUpdateCompanionBuilder,
          (
            AnimalNoteRow,
            BaseReferences<_$AppDatabase, $AnimalNotesTable, AnimalNoteRow>,
          ),
          AnimalNoteRow,
          PrefetchHooks Function()
        > {
  $$AnimalNotesTableTableManager(_$AppDatabase db, $AnimalNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> animalId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalNotesCompanion(
                animalId: animalId,
                note: note,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String animalId,
                required String note,
                required DateTime updatedAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalNotesCompanion.insert(
                animalId: animalId,
                note: note,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnimalNotesTable, AnimalNoteRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AnimalNotesTable,
                    AnimalNoteRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimalNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimalNotesTable,
      AnimalNoteRow,
      $$AnimalNotesTableFilterComposer,
      $$AnimalNotesTableOrderingComposer,
      $$AnimalNotesTableAnnotationComposer,
      $$AnimalNotesTableCreateCompanionBuilder,
      $$AnimalNotesTableUpdateCompanionBuilder,
      (
        AnimalNoteRow,
        BaseReferences<_$AppDatabase, $AnimalNotesTable, AnimalNoteRow>,
      ),
      AnimalNoteRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AnimalNotesTableTableManager get animalNotes =>
      $$AnimalNotesTableTableManager(_db, _db.animalNotes);
}
