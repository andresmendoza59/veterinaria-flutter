import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/datasources/local/itinerary_local_datasource.dart';
import 'package:flutter_app/data/datasources/remote/itinerary_remote_datasource.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

class SyncReport {
  final int synced;
  final int failed;
  final int rejected;

  const SyncReport({this.synced = 0, this.failed = 0, this.rejected = 0});
}

class ItineraryRepository {
  final ItineraryLocalDataSource local;
  final ItineraryRemoteDataSource? remote;

  ItineraryRepository({required this.local, this.remote});

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

    return activity;
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

    return updated;
  }

  Future<void> discard({required String id, required String uid}) async {
    final current = await local.getById(id);

    if (current == null || current.ownerUid != uid || !current.pendingSync) {
      throw const ItineraryException(
        'Solo puedes descartar cambios pendientes de envío',
      );
    }

    await local.delete(id);
  }

  Future<SyncReport> syncPending({required String uid}) async =>
      const SyncReport();

  Future<int> refreshFromRemote() async => 0;

  Future<ItineraryActivity> requestReturn({
    required String id,
    required String uid,
    required UserRole role,
    required String reason,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> approveSchedule({
    required String id,
    required String uid,
    required UserRole role,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> rejectProposal({
    required String id,
    required String uid,
    required UserRole role,
    required String reason,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> returnToProposal({
    required String id,
    required String uid,
    required UserRole role,
    required String reason,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> approveCost({
    required String id,
    required String uid,
    required UserRole role,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> cancelActivity({
    required String id,
    required String uid,
    required UserRole role,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> markDone({
    required String id,
    required String uid,
    required UserRole role,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );

  Future<ItineraryActivity> closeCost({
    required String id,
    required String uid,
    required UserRole role,
    required int realCost,
  }) async =>
      throw const ItineraryTemporaryException(
        'Esta operación requiere conexión con el servidor',
      );
}
