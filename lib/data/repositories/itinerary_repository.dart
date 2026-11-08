import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/datasources/local/itinerary_local_datasource.dart';
import 'package:flutter_app/data/datasources/remote/itinerary_remote_datasource.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/validators/activity_filters.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

class SyncReport {
  final int synced;
  final int failed;
  final int rejected;

  const SyncReport({this.synced = 0, this.failed = 0, this.rejected = 0});
}

/// Resultado de leer las actividades compartidas del viaje.
/// fromCache = true significa que Firestore no respondió y se muestra lo
/// último guardado en Drift; la pantalla debe avisarlo.
class ActivitiesResult {
  final List<ItineraryActivity> items;
  final bool fromCache;

  const ActivitiesResult({required this.items, required this.fromCache});
}

class ItineraryRepository {
  final ItineraryLocalDataSource local;
  final ItineraryRemoteDataSource? remote;

  ItineraryRepository({required this.local, this.remote});

  /// Lectura con respaldo: primero intenta traer lo último de Firestore
  /// (actualiza la caché de Drift); si falla, usa lo que ya hay en Drift.
  Future<ActivitiesResult> loadShared({required String uid}) async {
    final refreshed = await tryRefreshFromRemote();
    final all = await local.getAll();
    final visible = ActivityFilters.visibleFor(all, uid);
    return ActivitiesResult(items: visible, fromCache: !refreshed);
  }

  /// Devuelve true si Firestore respondió y la caché local quedó al día.
  Future<bool> tryRefreshFromRemote() async {
    try {
      await refreshFromRemote();
      return true;
    } catch (_) {
      return false;
    }
  }

  DateTime _stamp(DateTime? previous) {
    final now = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000,
    );
    if (previous != null && !now.isAfter(previous)) {
      return previous.add(const Duration(seconds: 1));
    }
    return now;
  }

  void _validate({required DateTime startAt, required int estimatedCost}) {
    final windowError = ItineraryRules.validateWindow(
      startAt: startAt,
      endAt: TripConfig.slotEnd(startAt),
    );
    if (windowError != null) throw ItineraryException(windowError);
    if (estimatedCost < 0 || estimatedCost > TripConfig.totalBudget) {
      throw const ItineraryException(
        'El costo no puede ser negativo ni superar el presupuesto del viaje',
      );
    }
  }

  Future<ItineraryActivity?> getById(String id) => local.getById(id);

  Future<List<ItineraryActivity>> getMine(String uid) => local.getByOwner(uid);

  Future<List<ItineraryActivity>> getAll() => local.getAll();

  Future<List<ItineraryActivity>> getByStatuses(
    Set<ActivityStatus> statuses,
  ) =>
      local.getByStatuses(statuses);

  Future<List<ItineraryActivity>> getFiltered({
    String? category,
    DateTime? fromInclusive,
    DateTime? toExclusive,
  }) =>
      local.getFiltered(
        category: category,
        fromInclusive: fromInclusive,
        toExclusive: toExclusive,
      );

  Future<List<String>> getCategories() => local.getCategories();

  Future<ItineraryActivity> createProposal({
    required String ownerUid,
    required CatalogActivity option,
    required DateTime startAt,
    required int estimatedCost,
  }) async {
    _validate(startAt: startAt, estimatedCost: estimatedCost);

    final activity = ItineraryActivity(
      id: ItineraryActivity.generateId(ownerUid),
      ownerUid: ownerUid,
      catalogId: option.id,
      title: option.name,
      category: option.category,
      location: option.location,
      startAt: startAt,
      endAt: TripConfig.slotEnd(startAt),
      estimatedCost: estimatedCost,
      status: ActivityStatus.proposed,
      slotId: '',
      reservedCost: 0,
      realCost: 0,
      reason: '',
      returnRequested: false,
      updatedAt: _stamp(null),
      pendingSync: true,
      syncError: '',
    );

    await local.upsert(activity);

    return _pushBestEffort(activity);
  }

  Future<ItineraryActivity> editProposal({
    required String uid,
    required ItineraryActivity activity,
    required DateTime startAt,
    required int estimatedCost,
  }) async {
    final current = await local.getById(activity.id);

    if (current == null) {
      throw const ItineraryException('La propuesta ya no existe');
    }

    final actionError = ItineraryRules.checkAction(
      action: ActivityAction.edit,
      role: UserRole.member,
      uid: uid,
      activity: current,
      now: DateTime.now(),
    );
    if (actionError != null) throw ItineraryException(actionError);

    _validate(startAt: startAt, estimatedCost: estimatedCost);

    final updated = current.copyWith(
      startAt: startAt,
      endAt: TripConfig.slotEnd(startAt),
      estimatedCost: estimatedCost,
      reason: '',
      syncError: '',
      pendingSync: true,
      updatedAt: _stamp(current.updatedAt),
    );

    await local.upsert(updated);

    return _pushBestEffort(updated);
  }

  Future<void> discard({required String id, required String uid}) async {
    final current = await local.getById(id);

    if (current == null || current.ownerUid != uid || !current.pendingSync) {
      throw const ItineraryException(
        'Solo puedes descartar cambios pendientes de envío',
      );
    }

    await local.delete(id);

    if (remote != null) {
      try {
        await refreshFromRemote();
      } catch (_) {
        return;
      }
    }
  }

  Future<SyncReport> syncPending({required String uid}) async {
    final source = remote;
    if (source == null) return const SyncReport();

    final queued = await local.getQueued(uid);

    var synced = 0;
    var failed = 0;
    var rejected = 0;

    for (final row in queued) {
      switch (await _syncOne(source, row)) {
        case _SyncResult.synced:
          synced++;
        case _SyncResult.failed:
          failed++;
        case _SyncResult.rejected:
          rejected++;
      }
    }

    return SyncReport(synced: synced, failed: failed, rejected: rejected);
  }

  Future<int> refreshFromRemote() async {
    final source = remote;
    if (source == null) return 0;

    final all = await source.fetchAll();
    await local.applyRemote(all);

    return all.length;
  }

  Future<_SyncResult> _syncOne(
    ItineraryRemoteDataSource source,
    ItineraryActivity row,
  ) async {
    try {
      await source.pushProposal(row);
      final marked = await local.markSynced(
        id: row.id,
        sentUpdatedAt: row.updatedAt,
      );
      return marked ? _SyncResult.synced : _SyncResult.failed;
    } on ItineraryRejectedException catch (error) {
      await local.markRejected(
        id: row.id,
        sentUpdatedAt: row.updatedAt,
        error: error.message,
      );
      return _SyncResult.rejected;
    } catch (_) {
      return _SyncResult.failed;
    }
  }

  Future<ItineraryActivity> _pushBestEffort(ItineraryActivity activity) async {
    final source = remote;
    if (source == null) return activity;

    try {
      await _syncOne(source, activity);
    } catch (_) {
      return activity;
    }

    return await local.getById(activity.id) ?? activity;
  }

  ItineraryRemoteDataSource _requireRemote() {
    final source = remote;
    if (source == null) {
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );
    }
    return source;
  }

  Future<ItineraryActivity> _decide(
    Future<ItineraryActivity> Function(ItineraryRemoteDataSource source)
        operation,
  ) async {
    final updated = await operation(_requireRemote());

    final existing = await local.getById(updated.id);
    if (existing == null || !existing.pendingSync) {
      await local.upsert(updated);
    }

    return updated;
  }

  Future<ItineraryActivity> requestReturn({
    required String id,
    required String uid,
    required UserRole role,
    required String reason,
  }) =>
      _decide(
        (source) => source.requestReturn(
          activityId: id,
          uid: uid,
          role: role,
          reason: reason,
        ),
      );

  Future<ItineraryActivity> approveSchedule({
    required String id,
    required String uid,
    required UserRole role,
  }) =>
      _decide(
        (source) => source.approveSchedule(
          activityId: id,
          uid: uid,
          role: role,
        ),
      );

  Future<ItineraryActivity> rejectProposal({
    required String id,
    required String uid,
    required UserRole role,
    required String reason,
  }) =>
      _decide(
        (source) => source.rejectProposal(
          activityId: id,
          uid: uid,
          role: role,
          reason: reason,
        ),
      );

  Future<ItineraryActivity> returnToProposal({
    required String id,
    required String uid,
    required UserRole role,
    required String reason,
  }) =>
      _decide(
        (source) => source.returnToProposal(
          activityId: id,
          uid: uid,
          role: role,
          reason: reason,
        ),
      );

  Future<ItineraryActivity> approveCost({
    required String id,
    required String uid,
    required UserRole role,
  }) =>
      _decide(
        (source) => source.approveCost(activityId: id, uid: uid, role: role),
      );

  Future<ItineraryActivity> cancelActivity({
    required String id,
    required String uid,
    required UserRole role,
  }) =>
      _decide(
        (source) => source.cancelActivity(activityId: id, uid: uid, role: role),
      );

  Future<ItineraryActivity> markDone({
    required String id,
    required String uid,
    required UserRole role,
  }) =>
      _decide(
        (source) => source.markDone(activityId: id, uid: uid, role: role),
      );

  Future<ItineraryActivity> closeCost({
    required String id,
    required String uid,
    required UserRole role,
    required int realCost,
  }) =>
      _decide(
        (source) => source.closeCost(
          activityId: id,
          uid: uid,
          role: role,
          realCost: realCost,
        ),
      );
}

enum _SyncResult { synced, failed, rejected }
