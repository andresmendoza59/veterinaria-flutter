import 'package:drift/drift.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';

class ItineraryLocalDataSource {
  final AppDatabase db;

  ItineraryLocalDataSource(this.db);

  ItineraryActivity _toDomain(ItineraryActivityRow row) {
    return ItineraryActivity(
      id: row.id,
      ownerUid: row.ownerUid,
      catalogId: row.catalogId,
      title: row.title,
      category: row.category,
      location: row.location,
      startAt: row.startAt,
      endAt: row.endAt,
      estimatedCost: row.estimatedCost,
      status: ActivityStatus.fromValue(row.status),
      slotId: row.slotId,
      reservedCost: row.reservedCost,
      realCost: row.realCost,
      reason: row.reason,
      returnRequested: row.returnRequested,
      updatedAt: row.updatedAt,
      pendingSync: row.pendingSync,
      syncError: row.syncError,
    );
  }

  Future<ItineraryActivity?> getById(String id) async {
    final query = db.select(db.itineraryActivities)
      ..where((t) => t.id.equals(id));

    final row = await query.getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  Future<List<ItineraryActivity>> getByOwner(String ownerUid) async {
    final rows = await (db.select(db.itineraryActivities)
          ..where((t) => t.ownerUid.equals(ownerUid))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<List<ItineraryActivity>> getAll() async {
    final rows = await (db.select(db.itineraryActivities)
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<List<ItineraryActivity>> getByStatuses(
    Set<ActivityStatus> statuses,
  ) async {
    if (statuses.isEmpty) return <ItineraryActivity>[];

    final values = statuses.map((s) => s.value).toList();

    final rows = await (db.select(db.itineraryActivities)
          ..where((t) => t.pendingSync.equals(false) & t.status.isIn(values))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<List<ItineraryActivity>> getFiltered({
    String? category,
    DateTime? fromInclusive,
    DateTime? toExclusive,
  }) async {
    final rows = await (db.select(db.itineraryActivities)
          ..where((t) {
            Expression<bool> condition = const Constant(true);
            if (category != null) {
              condition = condition & t.category.equals(category);
            }
            if (fromInclusive != null) {
              condition =
                  condition & t.startAt.isBiggerOrEqualValue(fromInclusive);
            }
            if (toExclusive != null) {
              condition = condition & t.startAt.isSmallerThanValue(toExclusive);
            }
            return condition;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<List<String>> getCategories() async {
    final all = await getAll();

    return all.map((a) => a.category).toSet().toList()..sort();
  }

  Future<List<ItineraryActivity>> getQueued(String ownerUid) async {
    final rows = await (db.select(db.itineraryActivities)
          ..where(
            (t) =>
                t.ownerUid.equals(ownerUid) &
                t.pendingSync.equals(true) &
                t.syncError.equals(''),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<void> upsert(ItineraryActivity activity) async {
    await db.into(db.itineraryActivities).insertOnConflictUpdate(
          ItineraryActivitiesCompanion.insert(
            id: activity.id,
            ownerUid: activity.ownerUid,
            catalogId: activity.catalogId,
            title: activity.title,
            category: activity.category,
            location: activity.location,
            startAt: activity.startAt,
            endAt: activity.endAt,
            estimatedCost: activity.estimatedCost,
            status: activity.status.value,
            slotId: Value(activity.slotId),
            reservedCost: Value(activity.reservedCost),
            realCost: Value(activity.realCost),
            reason: Value(activity.reason),
            returnRequested: Value(activity.returnRequested),
            updatedAt: activity.updatedAt,
            pendingSync: Value(activity.pendingSync),
            syncError: Value(activity.syncError),
          ),
        );
  }

  Future<bool> markSynced({
    required String id,
    required DateTime sentUpdatedAt,
  }) async {
    final updated = await (db.update(db.itineraryActivities)
          ..where(
            (t) =>
                t.id.equals(id) &
                t.updatedAt.equals(sentUpdatedAt) &
                t.pendingSync.equals(true),
          ))
        .write(
      const ItineraryActivitiesCompanion(
        pendingSync: Value(false),
        syncError: Value(''),
      ),
    );

    return updated > 0;
  }

  Future<bool> markRejected({
    required String id,
    required DateTime sentUpdatedAt,
    required String error,
  }) async {
    final updated = await (db.update(db.itineraryActivities)
          ..where(
            (t) =>
                t.id.equals(id) &
                t.updatedAt.equals(sentUpdatedAt) &
                t.pendingSync.equals(true),
          ))
        .write(ItineraryActivitiesCompanion(syncError: Value(error)));

    return updated > 0;
  }

  Future<void> delete(String id) async {
    await (db.delete(db.itineraryActivities)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> applyRemote(List<ItineraryActivity> remote) async {
    await db.transaction(() async {
      final remoteIds = remote.map((a) => a.id).toSet();

      final syncedRows = await (db.select(db.itineraryActivities)
            ..where((t) => t.pendingSync.equals(false)))
          .get();

      for (final row in syncedRows) {
        if (!remoteIds.contains(row.id)) {
          await delete(row.id);
        }
      }

      for (final activity in remote) {
        final existing = await getById(activity.id);

        if (existing != null && existing.pendingSync) continue;

        await upsert(activity.copyWith(pendingSync: false, syncError: ''));
      }
    });
  }
}
