import 'dart:async' show TimeoutException;
import 'dart:math' show max;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/core/app_logger.dart';
import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

class ItineraryRemoteDataSource {
  final FirebaseFirestore firestore;

  ItineraryRemoteDataSource(this.firestore);

  static const Duration _timeout = Duration(seconds: 15);

  DocumentReference<Map<String, dynamic>> _activityRef(String id) =>
      firestore.collection('activities').doc(id);

  DocumentReference<Map<String, dynamic>> _slotRef(String slotId) =>
      firestore.collection('slots').doc(slotId);

  DocumentReference<Map<String, dynamic>> get _budgetRef =>
      firestore.collection('budget').doc('trip');

  String _now() => DateTime.now().toIso8601String();

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation().timeout(_timeout);
    } on ItineraryException {
      rethrow;
    } on TimeoutException {
      throw const ItineraryTemporaryException(
        'El servidor no respondió. Intenta de nuevo',
      );
    } on FirebaseException catch (error) {
      AppLogger.warning('[Itinerary] ${error.code}');
      switch (error.code) {
        case 'permission-denied':
          throw const ItineraryRejectedException(
            'No tienes permiso para esta operación',
          );
        case 'unavailable':
        case 'deadline-exceeded':
        case 'aborted':
        case 'cancelled':
        case 'network-request-failed':
          throw const ItineraryTemporaryException(
            'Sin conexión con el servidor. Intenta de nuevo',
          );
        default:
          throw const ItineraryTemporaryException(
            'No se pudo completar la operación',
          );
      }
    } catch (_) {
      AppLogger.warning('[Itinerary] error inesperado');
      throw const ItineraryTemporaryException(
        'No se pudo completar la operación',
      );
    }
  }

  void _ensure(String? error) {
    if (error != null) throw ItineraryRejectedException(error);
  }

  String _validReason(String reason) {
    _ensure(ItineraryRules.validateReason(reason));
    return reason.trim();
  }

  Future<ItineraryActivity> _load(Transaction tx, String id) async {
    final snapshot = await tx.get(_activityRef(id));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const ItineraryRejectedException('La actividad ya no existe');
    }
    return ItineraryActivity.fromJson(data);
  }

  Future<({int reserved, int spent})> _loadBudget(Transaction tx) async {
    final snapshot = await tx.get(_budgetRef);
    final data = snapshot.data();
    return (
      reserved: (data?['reserved'] as num?)?.toInt() ?? 0,
      spent: (data?['spent'] as num?)?.toInt() ?? 0,
    );
  }

  ItineraryActivity _apply(
    Transaction tx,
    ItineraryActivity current,
    Map<String, Object?> changes,
  ) {
    final stamped = <String, Object?>{...changes, 'updated_at': _now()};
    tx.update(_activityRef(current.id), Map<Object, Object?>.from(stamped));
    return ItineraryActivity.fromJson({...current.toJson(), ...stamped});
  }

  Future<void> pushProposal(ItineraryActivity activity) {
    return _guard(
      () => firestore.runTransaction<void>((tx) async {
        final ref = _activityRef(activity.id);
        final snapshot = await tx.get(ref);
        final remote = snapshot.data();
        if (snapshot.exists && remote != null) {
          if (remote['status'] != ActivityStatus.proposed.value) {
            throw const ItineraryRejectedException(
              'La actividad ya fue procesada; descarta tu cambio o revisa su estado',
            );
          }
          if (remote['owner_uid'] != activity.ownerUid) {
            throw const ItineraryRejectedException(
              'La actividad pertenece a otro usuario',
            );
          }
        }
        tx.set(ref, activity.toJson());
      }),
    );
  }

  Future<List<ItineraryActivity>> fetchAll() {
    return _guard(() async {
      final snapshot = await firestore
          .collection('activities')
          .get(const GetOptions(source: Source.server));
      final result = <ItineraryActivity>[];
      for (final doc in snapshot.docs) {
        try {
          result.add(ItineraryActivity.fromJson(doc.data()));
        } catch (_) {
          AppLogger.warning('[Itinerary] documento remoto inválido omitido');
        }
      }
      return result;
    });
  }

  Future<ItineraryActivity> approveSchedule({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.approveSchedule,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        final slotId = TripConfig.slotId(current.startAt);
        final slotRef = _slotRef(slotId);
        final slotSnapshot = await tx.get(slotRef);
        if (slotSnapshot.exists &&
            slotSnapshot.data()?['activity_id'] != current.id) {
          throw const ItineraryRejectedException(
            'La franja ya está ocupada por otra actividad',
          );
        }
        if (!slotSnapshot.exists) {
          tx.set(slotRef, {'activity_id': current.id, 'updated_at': _now()});
        }
        return _apply(tx, current, {
          'status': ActivityStatus.scheduleApproved.value,
          'slot_id': slotId,
          'return_requested': false,
          'reason': '',
        });
      }),
    );
  }

  Future<ItineraryActivity> rejectProposal({
    required String activityId,
    required String uid,
    required UserRole role,
    required String reason,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.reject,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        final text = _validReason(reason);
        return _apply(tx, current, {
          'status': ActivityStatus.rejected.value,
          'reason': text,
        });
      }),
    );
  }

  Future<ItineraryActivity> requestReturn({
    required String activityId,
    required String uid,
    required UserRole role,
    required String reason,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.requestReturn,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        final text = _validReason(reason);
        return _apply(tx, current, {
          'return_requested': true,
          'reason': text,
        });
      }),
    );
  }

  Future<ItineraryActivity> returnToProposal({
    required String activityId,
    required String uid,
    required UserRole role,
    required String reason,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.returnToProposal,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        final text = _validReason(reason);
        final slotRef = _slotRef(TripConfig.slotId(current.startAt));
        final slotSnapshot = await tx.get(slotRef);
        if (slotSnapshot.exists &&
            slotSnapshot.data()?['activity_id'] == current.id) {
          tx.delete(slotRef);
        }
        return _apply(tx, current, {
          'status': ActivityStatus.proposed.value,
          'slot_id': '',
          'return_requested': false,
          'reason': text,
        });
      }),
    );
  }

  Future<ItineraryActivity> approveCost({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        final budget = await _loadBudget(tx);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.approveCost,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        final cost = current.estimatedCost;
        _ensure(
          ItineraryRules.checkReserve(
            reserved: budget.reserved,
            spent: budget.spent,
            cost: cost,
          ),
        );
        tx.set(_budgetRef, {
          'reserved': budget.reserved + cost,
          'spent': budget.spent,
        });
        return _apply(tx, current, {
          'status': ActivityStatus.confirmed.value,
          'reserved_cost': cost,
        });
      }),
    );
  }

  Future<ItineraryActivity> cancelActivity({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        final slotRef = _slotRef(TripConfig.slotId(current.startAt));
        final slotSnapshot = await tx.get(slotRef);
        final budgetSnapshot = await tx.get(_budgetRef);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.cancel,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        if (slotSnapshot.exists &&
            slotSnapshot.data()?['activity_id'] == current.id) {
          tx.delete(slotRef);
        }
        if (budgetSnapshot.exists && current.reservedCost > 0) {
          final reserved =
              (budgetSnapshot.data()?['reserved'] as num?)?.toInt() ?? 0;
          tx.update(_budgetRef, {
            'reserved': max(0, reserved - current.reservedCost),
          });
        }
        return _apply(tx, current, {
          'status': ActivityStatus.cancelled.value,
          'slot_id': '',
          'reserved_cost': 0,
        });
      }),
    );
  }

  Future<ItineraryActivity> markDone({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.markDone,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        return _apply(tx, current, {'status': ActivityStatus.done.value});
      }),
    );
  }

  Future<ItineraryActivity> closeCost({
    required String activityId,
    required String uid,
    required UserRole role,
    required int realCost,
  }) {
    return _guard(
      () => firestore.runTransaction<ItineraryActivity>((tx) async {
        final current = await _load(tx, activityId);
        final budget = await _loadBudget(tx);
        _ensure(
          ItineraryRules.checkAction(
            action: ActivityAction.closeCost,
            role: role,
            uid: uid,
            activity: current,
            now: DateTime.now(),
          ),
        );
        _ensure(
          ItineraryRules.checkCloseCost(
            activity: current,
            realCost: realCost,
            reserved: budget.reserved,
            spent: budget.spent,
          ),
        );
        tx.set(_budgetRef, {
          'reserved': max(0, budget.reserved - current.reservedCost),
          'spent': budget.spent + realCost,
        });
        return _apply(tx, current, {
          'status': ActivityStatus.costClosed.value,
          'real_cost': realCost,
          'reserved_cost': 0,
        });
      }),
    );
  }
}
