// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HighScoresTable extends HighScores
    with TableInfo<$HighScoresTable, HighScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, score, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'high_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<HighScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HighScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HighScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HighScoresTable createAlias(String alias) {
    return $HighScoresTable(attachedDatabase, alias);
  }
}

class HighScore extends DataClass implements Insertable<HighScore> {
  final int id;
  final String name;
  final int score;
  final DateTime createdAt;
  const HighScore({
    required this.id,
    required this.name,
    required this.score,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['score'] = Variable<int>(score);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HighScoresCompanion toCompanion(bool nullToAbsent) {
    return HighScoresCompanion(
      id: Value(id),
      name: Value(name),
      score: Value(score),
      createdAt: Value(createdAt),
    );
  }

  factory HighScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HighScore(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      score: serializer.fromJson<int>(json['score']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'score': serializer.toJson<int>(score),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HighScore copyWith({
    int? id,
    String? name,
    int? score,
    DateTime? createdAt,
  }) => HighScore(
    id: id ?? this.id,
    name: name ?? this.name,
    score: score ?? this.score,
    createdAt: createdAt ?? this.createdAt,
  );
  HighScore copyWithCompanion(HighScoresCompanion data) {
    return HighScore(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      score: data.score.present ? data.score.value : this.score,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HighScore(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, score, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HighScore &&
          other.id == this.id &&
          other.name == this.name &&
          other.score == this.score &&
          other.createdAt == this.createdAt);
}

class HighScoresCompanion extends UpdateCompanion<HighScore> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> score;
  final Value<DateTime> createdAt;
  const HighScoresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.score = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HighScoresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int score,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       score = Value(score);
  static Insertable<HighScore> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? score,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (score != null) 'score': score,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HighScoresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? score,
    Value<DateTime>? createdAt,
  }) {
    return HighScoresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighScoresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HighScoresTable highScores = $HighScoresTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [highScores];
}

typedef $$HighScoresTableCreateCompanionBuilder =
    HighScoresCompanion Function({
      Value<int> id,
      required String name,
      required int score,
      Value<DateTime> createdAt,
    });
typedef $$HighScoresTableUpdateCompanionBuilder =
    HighScoresCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> score,
      Value<DateTime> createdAt,
    });

class $$HighScoresTableFilterComposer
    extends Composer<_$AppDatabase, $HighScoresTable> {
  $$HighScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HighScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $HighScoresTable> {
  $$HighScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HighScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $HighScoresTable> {
  $$HighScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HighScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HighScoresTable,
          HighScore,
          $$HighScoresTableFilterComposer,
          $$HighScoresTableOrderingComposer,
          $$HighScoresTableAnnotationComposer,
          $$HighScoresTableCreateCompanionBuilder,
          $$HighScoresTableUpdateCompanionBuilder,
          (
            HighScore,
            BaseReferences<_$AppDatabase, $HighScoresTable, HighScore>,
          ),
          HighScore,
          PrefetchHooks Function()
        > {
  $$HighScoresTableTableManager(_$AppDatabase db, $HighScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HighScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HighScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HighScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HighScoresCompanion(
                id: id,
                name: name,
                score: score,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int score,
                Value<DateTime> createdAt = const Value.absent(),
              }) => HighScoresCompanion.insert(
                id: id,
                name: name,
                score: score,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HighScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HighScoresTable,
      HighScore,
      $$HighScoresTableFilterComposer,
      $$HighScoresTableOrderingComposer,
      $$HighScoresTableAnnotationComposer,
      $$HighScoresTableCreateCompanionBuilder,
      $$HighScoresTableUpdateCompanionBuilder,
      (HighScore, BaseReferences<_$AppDatabase, $HighScoresTable, HighScore>),
      HighScore,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HighScoresTableTableManager get highScores =>
      $$HighScoresTableTableManager(_db, _db.highScores);
}
