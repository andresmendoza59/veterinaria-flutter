// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItineraryActivitiesTable extends ItineraryActivities
    with TableInfo<$ItineraryActivitiesTable, ItineraryActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItineraryActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedCostMeta = const VerificationMeta(
    'estimatedCost',
  );
  @override
  late final GeneratedColumn<int> estimatedCost = GeneratedColumn<int>(
    'estimated_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<String> slotId = GeneratedColumn<String>(
    'slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reservedCostMeta = const VerificationMeta(
    'reservedCost',
  );
  @override
  late final GeneratedColumn<int> reservedCost = GeneratedColumn<int>(
    'reserved_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _realCostMeta = const VerificationMeta(
    'realCost',
  );
  @override
  late final GeneratedColumn<int> realCost = GeneratedColumn<int>(
    'real_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _returnRequestedMeta = const VerificationMeta(
    'returnRequested',
  );
  @override
  late final GeneratedColumn<bool> returnRequested = GeneratedColumn<bool>(
    'return_requested',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("return_requested" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    catalogId,
    title,
    category,
    location,
    startAt,
    endAt,
    estimatedCost,
    status,
    slotId,
    reservedCost,
    realCost,
    reason,
    returnRequested,
    updatedAt,
    pendingSync,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itinerary_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItineraryActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
        _estimatedCostMeta,
        estimatedCost.isAcceptableOrUnknown(
          data['estimated_cost']!,
          _estimatedCostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedCostMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    }
    if (data.containsKey('reserved_cost')) {
      context.handle(
        _reservedCostMeta,
        reservedCost.isAcceptableOrUnknown(
          data['reserved_cost']!,
          _reservedCostMeta,
        ),
      );
    }
    if (data.containsKey('real_cost')) {
      context.handle(
        _realCostMeta,
        realCost.isAcceptableOrUnknown(data['real_cost']!, _realCostMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('return_requested')) {
      context.handle(
        _returnRequestedMeta,
        returnRequested.isAcceptableOrUnknown(
          data['return_requested']!,
          _returnRequestedMeta,
        ),
      );
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
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItineraryActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItineraryActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      estimatedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_cost'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_id'],
      )!,
      reservedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reserved_cost'],
      )!,
      realCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}real_cost'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      returnRequested: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}return_requested'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      )!,
    );
  }

  @override
  $ItineraryActivitiesTable createAlias(String alias) {
    return $ItineraryActivitiesTable(attachedDatabase, alias);
  }
}

class ItineraryActivityRow extends DataClass
    implements Insertable<ItineraryActivityRow> {
  final String id;
  final String ownerUid;
  final String catalogId;
  final String title;
  final String category;
  final String location;
  final DateTime startAt;
  final DateTime endAt;
  final int estimatedCost;
  final String status;
  final String slotId;
  final int reservedCost;
  final int realCost;
  final String reason;
  final bool returnRequested;
  final DateTime updatedAt;
  final bool pendingSync;
  final String syncError;
  const ItineraryActivityRow({
    required this.id,
    required this.ownerUid,
    required this.catalogId,
    required this.title,
    required this.category,
    required this.location,
    required this.startAt,
    required this.endAt,
    required this.estimatedCost,
    required this.status,
    required this.slotId,
    required this.reservedCost,
    required this.realCost,
    required this.reason,
    required this.returnRequested,
    required this.updatedAt,
    required this.pendingSync,
    required this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_uid'] = Variable<String>(ownerUid);
    map['catalog_id'] = Variable<String>(catalogId);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['location'] = Variable<String>(location);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['estimated_cost'] = Variable<int>(estimatedCost);
    map['status'] = Variable<String>(status);
    map['slot_id'] = Variable<String>(slotId);
    map['reserved_cost'] = Variable<int>(reservedCost);
    map['real_cost'] = Variable<int>(realCost);
    map['reason'] = Variable<String>(reason);
    map['return_requested'] = Variable<bool>(returnRequested);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['sync_error'] = Variable<String>(syncError);
    return map;
  }

  ItineraryActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ItineraryActivitiesCompanion(
      id: Value(id),
      ownerUid: Value(ownerUid),
      catalogId: Value(catalogId),
      title: Value(title),
      category: Value(category),
      location: Value(location),
      startAt: Value(startAt),
      endAt: Value(endAt),
      estimatedCost: Value(estimatedCost),
      status: Value(status),
      slotId: Value(slotId),
      reservedCost: Value(reservedCost),
      realCost: Value(realCost),
      reason: Value(reason),
      returnRequested: Value(returnRequested),
      updatedAt: Value(updatedAt),
      pendingSync: Value(pendingSync),
      syncError: Value(syncError),
    );
  }

  factory ItineraryActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItineraryActivityRow(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      location: serializer.fromJson<String>(json['location']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      estimatedCost: serializer.fromJson<int>(json['estimatedCost']),
      status: serializer.fromJson<String>(json['status']),
      slotId: serializer.fromJson<String>(json['slotId']),
      reservedCost: serializer.fromJson<int>(json['reservedCost']),
      realCost: serializer.fromJson<int>(json['realCost']),
      reason: serializer.fromJson<String>(json['reason']),
      returnRequested: serializer.fromJson<bool>(json['returnRequested']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      syncError: serializer.fromJson<String>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String>(ownerUid),
      'catalogId': serializer.toJson<String>(catalogId),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'location': serializer.toJson<String>(location),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'estimatedCost': serializer.toJson<int>(estimatedCost),
      'status': serializer.toJson<String>(status),
      'slotId': serializer.toJson<String>(slotId),
      'reservedCost': serializer.toJson<int>(reservedCost),
      'realCost': serializer.toJson<int>(realCost),
      'reason': serializer.toJson<String>(reason),
      'returnRequested': serializer.toJson<bool>(returnRequested),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'syncError': serializer.toJson<String>(syncError),
    };
  }

  ItineraryActivityRow copyWith({
    String? id,
    String? ownerUid,
    String? catalogId,
    String? title,
    String? category,
    String? location,
    DateTime? startAt,
    DateTime? endAt,
    int? estimatedCost,
    String? status,
    String? slotId,
    int? reservedCost,
    int? realCost,
    String? reason,
    bool? returnRequested,
    DateTime? updatedAt,
    bool? pendingSync,
    String? syncError,
  }) => ItineraryActivityRow(
    id: id ?? this.id,
    ownerUid: ownerUid ?? this.ownerUid,
    catalogId: catalogId ?? this.catalogId,
    title: title ?? this.title,
    category: category ?? this.category,
    location: location ?? this.location,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    estimatedCost: estimatedCost ?? this.estimatedCost,
    status: status ?? this.status,
    slotId: slotId ?? this.slotId,
    reservedCost: reservedCost ?? this.reservedCost,
    realCost: realCost ?? this.realCost,
    reason: reason ?? this.reason,
    returnRequested: returnRequested ?? this.returnRequested,
    updatedAt: updatedAt ?? this.updatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
    syncError: syncError ?? this.syncError,
  );
  ItineraryActivityRow copyWithCompanion(ItineraryActivitiesCompanion data) {
    return ItineraryActivityRow(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
      status: data.status.present ? data.status.value : this.status,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      reservedCost: data.reservedCost.present
          ? data.reservedCost.value
          : this.reservedCost,
      realCost: data.realCost.present ? data.realCost.value : this.realCost,
      reason: data.reason.present ? data.reason.value : this.reason,
      returnRequested: data.returnRequested.present
          ? data.returnRequested.value
          : this.returnRequested,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItineraryActivityRow(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('catalogId: $catalogId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('status: $status, ')
          ..write('slotId: $slotId, ')
          ..write('reservedCost: $reservedCost, ')
          ..write('realCost: $realCost, ')
          ..write('reason: $reason, ')
          ..write('returnRequested: $returnRequested, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    catalogId,
    title,
    category,
    location,
    startAt,
    endAt,
    estimatedCost,
    status,
    slotId,
    reservedCost,
    realCost,
    reason,
    returnRequested,
    updatedAt,
    pendingSync,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItineraryActivityRow &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.catalogId == this.catalogId &&
          other.title == this.title &&
          other.category == this.category &&
          other.location == this.location &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.estimatedCost == this.estimatedCost &&
          other.status == this.status &&
          other.slotId == this.slotId &&
          other.reservedCost == this.reservedCost &&
          other.realCost == this.realCost &&
          other.reason == this.reason &&
          other.returnRequested == this.returnRequested &&
          other.updatedAt == this.updatedAt &&
          other.pendingSync == this.pendingSync &&
          other.syncError == this.syncError);
}

class ItineraryActivitiesCompanion
    extends UpdateCompanion<ItineraryActivityRow> {
  final Value<String> id;
  final Value<String> ownerUid;
  final Value<String> catalogId;
  final Value<String> title;
  final Value<String> category;
  final Value<String> location;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<int> estimatedCost;
  final Value<String> status;
  final Value<String> slotId;
  final Value<int> reservedCost;
  final Value<int> realCost;
  final Value<String> reason;
  final Value<bool> returnRequested;
  final Value<DateTime> updatedAt;
  final Value<bool> pendingSync;
  final Value<String> syncError;
  final Value<int> rowid;
  const ItineraryActivitiesCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.status = const Value.absent(),
    this.slotId = const Value.absent(),
    this.reservedCost = const Value.absent(),
    this.realCost = const Value.absent(),
    this.reason = const Value.absent(),
    this.returnRequested = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItineraryActivitiesCompanion.insert({
    required String id,
    required String ownerUid,
    required String catalogId,
    required String title,
    required String category,
    required String location,
    required DateTime startAt,
    required DateTime endAt,
    required int estimatedCost,
    required String status,
    this.slotId = const Value.absent(),
    this.reservedCost = const Value.absent(),
    this.realCost = const Value.absent(),
    this.reason = const Value.absent(),
    this.returnRequested = const Value.absent(),
    required DateTime updatedAt,
    this.pendingSync = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUid = Value(ownerUid),
       catalogId = Value(catalogId),
       title = Value(title),
       category = Value(category),
       location = Value(location),
       startAt = Value(startAt),
       endAt = Value(endAt),
       estimatedCost = Value(estimatedCost),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<ItineraryActivityRow> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? catalogId,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? location,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<int>? estimatedCost,
    Expression<String>? status,
    Expression<String>? slotId,
    Expression<int>? reservedCost,
    Expression<int>? realCost,
    Expression<String>? reason,
    Expression<bool>? returnRequested,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendingSync,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (catalogId != null) 'catalog_id': catalogId,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (status != null) 'status': status,
      if (slotId != null) 'slot_id': slotId,
      if (reservedCost != null) 'reserved_cost': reservedCost,
      if (realCost != null) 'real_cost': realCost,
      if (reason != null) 'reason': reason,
      if (returnRequested != null) 'return_requested': returnRequested,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItineraryActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUid,
    Value<String>? catalogId,
    Value<String>? title,
    Value<String>? category,
    Value<String>? location,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<int>? estimatedCost,
    Value<String>? status,
    Value<String>? slotId,
    Value<int>? reservedCost,
    Value<int>? realCost,
    Value<String>? reason,
    Value<bool>? returnRequested,
    Value<DateTime>? updatedAt,
    Value<bool>? pendingSync,
    Value<String>? syncError,
    Value<int>? rowid,
  }) {
    return ItineraryActivitiesCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      catalogId: catalogId ?? this.catalogId,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      slotId: slotId ?? this.slotId,
      reservedCost: reservedCost ?? this.reservedCost,
      realCost: realCost ?? this.realCost,
      reason: reason ?? this.reason,
      returnRequested: returnRequested ?? this.returnRequested,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<int>(estimatedCost.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<String>(slotId.value);
    }
    if (reservedCost.present) {
      map['reserved_cost'] = Variable<int>(reservedCost.value);
    }
    if (realCost.present) {
      map['real_cost'] = Variable<int>(realCost.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (returnRequested.present) {
      map['return_requested'] = Variable<bool>(returnRequested.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItineraryActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('catalogId: $catalogId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('status: $status, ')
          ..write('slotId: $slotId, ')
          ..write('reservedCost: $reservedCost, ')
          ..write('realCost: $realCost, ')
          ..write('reason: $reason, ')
          ..write('returnRequested: $returnRequested, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogOptionsTable extends CatalogOptions
    with TableInfo<$CatalogOptionsTable, CatalogOptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _estimatedCostMeta = const VerificationMeta(
    'estimatedCost',
  );
  @override
  late final GeneratedColumn<int> estimatedCost = GeneratedColumn<int>(
    'estimated_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    location,
    description,
    estimatedCost,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogOptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
        _estimatedCostMeta,
        estimatedCost.isAcceptableOrUnknown(
          data['estimated_cost']!,
          _estimatedCostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedCostMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogOptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogOptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      estimatedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_cost'],
      )!,
    );
  }

  @override
  $CatalogOptionsTable createAlias(String alias) {
    return $CatalogOptionsTable(attachedDatabase, alias);
  }
}

class CatalogOptionRow extends DataClass
    implements Insertable<CatalogOptionRow> {
  final String id;
  final String name;
  final String category;
  final String location;
  final String description;
  final int estimatedCost;
  const CatalogOptionRow({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.estimatedCost,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['location'] = Variable<String>(location);
    map['description'] = Variable<String>(description);
    map['estimated_cost'] = Variable<int>(estimatedCost);
    return map;
  }

  CatalogOptionsCompanion toCompanion(bool nullToAbsent) {
    return CatalogOptionsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      location: Value(location),
      description: Value(description),
      estimatedCost: Value(estimatedCost),
    );
  }

  factory CatalogOptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogOptionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      location: serializer.fromJson<String>(json['location']),
      description: serializer.fromJson<String>(json['description']),
      estimatedCost: serializer.fromJson<int>(json['estimatedCost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'location': serializer.toJson<String>(location),
      'description': serializer.toJson<String>(description),
      'estimatedCost': serializer.toJson<int>(estimatedCost),
    };
  }

  CatalogOptionRow copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    String? description,
    int? estimatedCost,
  }) => CatalogOptionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    location: location ?? this.location,
    description: description ?? this.description,
    estimatedCost: estimatedCost ?? this.estimatedCost,
  );
  CatalogOptionRow copyWithCompanion(CatalogOptionsCompanion data) {
    return CatalogOptionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      description: data.description.present
          ? data.description.value
          : this.description,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogOptionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('estimatedCost: $estimatedCost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, location, description, estimatedCost);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogOptionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.location == this.location &&
          other.description == this.description &&
          other.estimatedCost == this.estimatedCost);
}

class CatalogOptionsCompanion extends UpdateCompanion<CatalogOptionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> location;
  final Value<String> description;
  final Value<int> estimatedCost;
  final Value<int> rowid;
  const CatalogOptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogOptionsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String location,
    this.description = const Value.absent(),
    required int estimatedCost,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       location = Value(location),
       estimatedCost = Value(estimatedCost);
  static Insertable<CatalogOptionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? location,
    Expression<String>? description,
    Expression<int>? estimatedCost,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String>? location,
    Value<String>? description,
    Value<int>? estimatedCost,
    Value<int>? rowid,
  }) {
    return CatalogOptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<int>(estimatedCost.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogOptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItineraryActivitiesTable itineraryActivities =
      $ItineraryActivitiesTable(this);
  late final $CatalogOptionsTable catalogOptions = $CatalogOptionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    itineraryActivities,
    catalogOptions,
  ];
}

typedef $$ItineraryActivitiesTableCreateCompanionBuilder =
    ItineraryActivitiesCompanion Function({
      required String id,
      required String ownerUid,
      required String catalogId,
      required String title,
      required String category,
      required String location,
      required DateTime startAt,
      required DateTime endAt,
      required int estimatedCost,
      required String status,
      Value<String> slotId,
      Value<int> reservedCost,
      Value<int> realCost,
      Value<String> reason,
      Value<bool> returnRequested,
      required DateTime updatedAt,
      Value<bool> pendingSync,
      Value<String> syncError,
      Value<int> rowid,
    });
typedef $$ItineraryActivitiesTableUpdateCompanionBuilder =
    ItineraryActivitiesCompanion Function({
      Value<String> id,
      Value<String> ownerUid,
      Value<String> catalogId,
      Value<String> title,
      Value<String> category,
      Value<String> location,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<int> estimatedCost,
      Value<String> status,
      Value<String> slotId,
      Value<int> reservedCost,
      Value<int> realCost,
      Value<String> reason,
      Value<bool> returnRequested,
      Value<DateTime> updatedAt,
      Value<bool> pendingSync,
      Value<String> syncError,
      Value<int> rowid,
    });

class $$ItineraryActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ItineraryActivitiesTable> {
  $$ItineraryActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reservedCost => $composableBuilder(
    column: $table.reservedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realCost => $composableBuilder(
    column: $table.realCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get returnRequested => $composableBuilder(
    column: $table.returnRequested,
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

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItineraryActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItineraryActivitiesTable> {
  $$ItineraryActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reservedCost => $composableBuilder(
    column: $table.reservedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realCost => $composableBuilder(
    column: $table.realCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get returnRequested => $composableBuilder(
    column: $table.returnRequested,
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

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItineraryActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItineraryActivitiesTable> {
  $$ItineraryActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get slotId =>
      $composableBuilder(column: $table.slotId, builder: (column) => column);

  GeneratedColumn<int> get reservedCost => $composableBuilder(
    column: $table.reservedCost,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realCost =>
      $composableBuilder(column: $table.realCost, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get returnRequested => $composableBuilder(
    column: $table.returnRequested,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ItineraryActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItineraryActivitiesTable,
          ItineraryActivityRow,
          $$ItineraryActivitiesTableFilterComposer,
          $$ItineraryActivitiesTableOrderingComposer,
          $$ItineraryActivitiesTableAnnotationComposer,
          $$ItineraryActivitiesTableCreateCompanionBuilder,
          $$ItineraryActivitiesTableUpdateCompanionBuilder,
          (
            ItineraryActivityRow,
            BaseReferences<
              _$AppDatabase,
              $ItineraryActivitiesTable,
              ItineraryActivityRow
            >,
          ),
          ItineraryActivityRow,
          PrefetchHooks Function()
        > {
  $$ItineraryActivitiesTableTableManager(
    _$AppDatabase db,
    $ItineraryActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItineraryActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItineraryActivitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ItineraryActivitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUid = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<int> estimatedCost = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> slotId = const Value.absent(),
                Value<int> reservedCost = const Value.absent(),
                Value<int> realCost = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> returnRequested = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<String> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItineraryActivitiesCompanion(
                id: id,
                ownerUid: ownerUid,
                catalogId: catalogId,
                title: title,
                category: category,
                location: location,
                startAt: startAt,
                endAt: endAt,
                estimatedCost: estimatedCost,
                status: status,
                slotId: slotId,
                reservedCost: reservedCost,
                realCost: realCost,
                reason: reason,
                returnRequested: returnRequested,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUid,
                required String catalogId,
                required String title,
                required String category,
                required String location,
                required DateTime startAt,
                required DateTime endAt,
                required int estimatedCost,
                required String status,
                Value<String> slotId = const Value.absent(),
                Value<int> reservedCost = const Value.absent(),
                Value<int> realCost = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> returnRequested = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<String> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItineraryActivitiesCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                catalogId: catalogId,
                title: title,
                category: category,
                location: location,
                startAt: startAt,
                endAt: endAt,
                estimatedCost: estimatedCost,
                status: status,
                slotId: slotId,
                reservedCost: reservedCost,
                realCost: realCost,
                reason: reason,
                returnRequested: returnRequested,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItineraryActivitiesTable, ItineraryActivityRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ItineraryActivitiesTable,
                    ItineraryActivityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItineraryActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItineraryActivitiesTable,
      ItineraryActivityRow,
      $$ItineraryActivitiesTableFilterComposer,
      $$ItineraryActivitiesTableOrderingComposer,
      $$ItineraryActivitiesTableAnnotationComposer,
      $$ItineraryActivitiesTableCreateCompanionBuilder,
      $$ItineraryActivitiesTableUpdateCompanionBuilder,
      (
        ItineraryActivityRow,
        BaseReferences<
          _$AppDatabase,
          $ItineraryActivitiesTable,
          ItineraryActivityRow
        >,
      ),
      ItineraryActivityRow,
      PrefetchHooks Function()
    >;
typedef $$CatalogOptionsTableCreateCompanionBuilder =
    CatalogOptionsCompanion Function({
      required String id,
      required String name,
      required String category,
      required String location,
      Value<String> description,
      required int estimatedCost,
      Value<int> rowid,
    });
typedef $$CatalogOptionsTableUpdateCompanionBuilder =
    CatalogOptionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<String> location,
      Value<String> description,
      Value<int> estimatedCost,
      Value<int> rowid,
    });

class $$CatalogOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogOptionsTable> {
  $$CatalogOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogOptionsTable> {
  $$CatalogOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogOptionsTable> {
  $$CatalogOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => column,
  );
}

class $$CatalogOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogOptionsTable,
          CatalogOptionRow,
          $$CatalogOptionsTableFilterComposer,
          $$CatalogOptionsTableOrderingComposer,
          $$CatalogOptionsTableAnnotationComposer,
          $$CatalogOptionsTableCreateCompanionBuilder,
          $$CatalogOptionsTableUpdateCompanionBuilder,
          (
            CatalogOptionRow,
            BaseReferences<
              _$AppDatabase,
              $CatalogOptionsTable,
              CatalogOptionRow
            >,
          ),
          CatalogOptionRow,
          PrefetchHooks Function()
        > {
  $$CatalogOptionsTableTableManager(
    _$AppDatabase db,
    $CatalogOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> estimatedCost = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogOptionsCompanion(
                id: id,
                name: name,
                category: category,
                location: location,
                description: description,
                estimatedCost: estimatedCost,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required String location,
                Value<String> description = const Value.absent(),
                required int estimatedCost,
                Value<int> rowid = const Value.absent(),
              }) => CatalogOptionsCompanion.insert(
                id: id,
                name: name,
                category: category,
                location: location,
                description: description,
                estimatedCost: estimatedCost,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogOptionsTable, CatalogOptionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogOptionsTable,
                    CatalogOptionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogOptionsTable,
      CatalogOptionRow,
      $$CatalogOptionsTableFilterComposer,
      $$CatalogOptionsTableOrderingComposer,
      $$CatalogOptionsTableAnnotationComposer,
      $$CatalogOptionsTableCreateCompanionBuilder,
      $$CatalogOptionsTableUpdateCompanionBuilder,
      (
        CatalogOptionRow,
        BaseReferences<_$AppDatabase, $CatalogOptionsTable, CatalogOptionRow>,
      ),
      CatalogOptionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItineraryActivitiesTableTableManager get itineraryActivities =>
      $$ItineraryActivitiesTableTableManager(_db, _db.itineraryActivities);
  $$CatalogOptionsTableTableManager get catalogOptions =>
      $$CatalogOptionsTableTableManager(_db, _db.catalogOptions);
}
