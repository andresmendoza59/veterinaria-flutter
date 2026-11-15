import 'dart:async' show TimeoutException;
import 'dart:math' show max;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/core/app_logger.dart';
import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/services/crash/crash_service.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

/// Totales del documento budget/trip.
class _BudgetTotals {
  final int reserved;
  final int spent;

  const _BudgetTotals({required this.reserved, required this.spent});
}

/// Habla con Firestore sobre las actividades, las franjas y el presupuesto.
///
/// Las decisiones (aprobar horario, aprobar costo, cancelar...) se hacen en
/// una transacción: Firestore guarda todos los cambios juntos o ninguno, así
/// dos personas no pueden ocupar la misma franja ni pasarse del presupuesto.
class ItineraryRemoteDataSource {
  final FirebaseFirestore firestore;
  // Opcional: registra en Crashlytics los errores inesperados (no fatales).
  final CrashService? crashService;

  ItineraryRemoteDataSource(this.firestore, {this.crashService});

  static const Duration _timeout = Duration(seconds: 15);

  // ---------------------------------------------------------------------
  // Direcciones de Firestore
  // ---------------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> _activityRef(String id) =>
      firestore.collection('activities').doc(id);

  DocumentReference<Map<String, dynamic>> _slotRef(String slotId) =>
      firestore.collection('slots').doc(slotId);

  DocumentReference<Map<String, dynamic>> get _budgetRef =>
      firestore.collection('budget').doc('trip');

  String _now() => DateTime.now().toIso8601String();

  // ---------------------------------------------------------------------
  // Transacciones y errores
  // ---------------------------------------------------------------------

  Future<void> _recordUnexpected(Object error, StackTrace stackTrace) async {
    final crash = crashService;
    if (crash == null) return;
    await crash.recordNonFatal(
      error,
      stackTrace,
      reason: 'Itinerario: error inesperado en Firestore',
    );
  }

  /// Rechazada = no tiene sentido reintentar. Temporal = se puede reintentar.
  ItineraryException _friendlyError(String firebaseCode) {
    switch (firebaseCode) {
      case 'permission-denied':
        return const ItineraryRejectedException(
          'No tienes permiso para esta operación',
        );
      case 'unavailable':
      case 'deadline-exceeded':
      case 'aborted':
      case 'cancelled':
      case 'network-request-failed':
        return const ItineraryTemporaryException(
          'Sin conexión con el servidor. Intenta de nuevo',
        );
      default:
        return const ItineraryTemporaryException(
          'No se pudo completar la operación',
        );
    }
  }

  /// Corta la espera a los 15 segundos y convierte cualquier error técnico en
  /// una excepción con un mensaje que el usuario entienda.
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
      throw _friendlyError(error.code);
    } catch (error, stackTrace) {
      // Error que no es de negocio ni de red: se avisa con un mensaje simple
      // y se registra como no fatal para poder diagnosticarlo.
      AppLogger.warning('[Itinerary] error inesperado');
      await _recordUnexpected(error, stackTrace);
      throw const ItineraryTemporaryException(
        'No se pudo completar la operación',
      );
    }
  }

  /// Ejecuta el trabajo dentro de una transacción de Firestore, con los
  /// errores ya traducidos a mensajes para el usuario.
  Future<ItineraryActivity> _inTransaction(
    Future<ItineraryActivity> Function(Transaction tx) work,
  ) {
    return _guard(() => firestore.runTransaction<ItineraryActivity>(work));
  }

  // ---------------------------------------------------------------------
  // Reglas de negocio
  // ---------------------------------------------------------------------

  /// Las reglas puras devuelven null si todo está bien o un mensaje si no.
  /// Si hay mensaje, se lanza y la transacción se cancela sin guardar nada.
  void _ensure(String? error) {
    if (error != null) throw ItineraryRejectedException(error);
  }

  /// Revisa que este rol pueda hacer esta acción sobre la actividad en su
  /// estado actual.
  void _checkAction(
    ActivityAction action,
    UserRole role,
    String uid,
    ItineraryActivity activity,
  ) {
    _ensure(
      ItineraryRules.checkAction(
        action: action,
        role: role,
        uid: uid,
        activity: activity,
        now: DateTime.now(),
      ),
    );
  }

  /// Valida el motivo y lo devuelve sin espacios sobrantes.
  String _validReason(String reason) {
    _ensure(ItineraryRules.validateReason(reason));
    return reason.trim();
  }

  /// Un reintento no puede pisar lo que otro rol ya decidió, ni la propuesta
  /// de otra persona. [remote] es null si la actividad aún no existe en la nube.
  void _checkRemoteProposal(
    Map<String, dynamic>? remote,
    ItineraryActivity activity,
  ) {
    if (remote == null) return;

    final stillProposal = remote['status'] == ActivityStatus.proposed.value;
    if (!stillProposal) {
      throw const ItineraryRejectedException(
        'La actividad ya fue procesada; descarta tu cambio o revisa su estado',
      );
    }

    final sameOwner = remote['owner_uid'] == activity.ownerUid;
    if (!sameOwner) {
      throw const ItineraryRejectedException(
        'La actividad pertenece a otro usuario',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Leer y escribir dentro de una transacción
  // ---------------------------------------------------------------------

  /// Lee la actividad tal como está ahora en Firestore.
  Future<ItineraryActivity> _load(Transaction tx, String id) async {
    final snapshot = await tx.get(_activityRef(id));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const ItineraryRejectedException('La actividad ya no existe');
    }
    return ItineraryActivity.fromJson(data);
  }

  /// Escribe los cambios en la actividad y devuelve la actividad actualizada.
  ItineraryActivity _apply(
    Transaction tx,
    ItineraryActivity current,
    Map<String, Object?> changes,
  ) {
    final stamped = <String, Object?>{...changes, 'updated_at': _now()};
    tx.update(_activityRef(current.id), Map<Object, Object?>.from(stamped));
    return ItineraryActivity.fromJson({...current.toJson(), ...stamped});
  }

  /// Convierte los documentos recibidos en actividades. Un documento dañado
  /// se omite con una advertencia, para no romper toda la lista.
  List<ItineraryActivity> _parseActivities(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final result = <ItineraryActivity>[];
    for (final doc in snapshot.docs) {
      try {
        result.add(ItineraryActivity.fromJson(doc.data()));
      } catch (_) {
        AppLogger.warning('[Itinerary] documento remoto inválido omitido');
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // Franjas
  // ---------------------------------------------------------------------

  /// Ocupa la franja de la actividad y devuelve su id. El documento de la
  /// franja es el "candado": si ya existe y es de otra actividad, rechaza.
  Future<String> _reserveSlot(
    Transaction tx,
    ItineraryActivity activity,
  ) async {
    final slotId = TripConfig.slotId(activity.startAt);
    final slotRef = _slotRef(slotId);
    final slot = await tx.get(slotRef);

    if (slot.exists) {
      final takenByOther = slot.data()?['activity_id'] != activity.id;
      if (takenByOther) {
        throw const ItineraryRejectedException(
          'La franja ya está ocupada por otra actividad',
        );
      }
      return slotId;
    }

    tx.set(slotRef, {'activity_id': activity.id, 'updated_at': _now()});
    return slotId;
  }

  /// Borra el documento de la franja, solo si la ocupaba esta actividad.
  void _releaseSlotIfOwned(
    Transaction tx,
    DocumentReference<Map<String, dynamic>> slotRef,
    DocumentSnapshot<Map<String, dynamic>> slot,
    String activityId,
  ) {
    final isOwner = slot.exists && slot.data()?['activity_id'] == activityId;
    if (isOwner) tx.delete(slotRef);
  }

  // ---------------------------------------------------------------------
  // Presupuesto
  // ---------------------------------------------------------------------

  /// Lee lo reservado y lo gastado. Si el documento aún no existe, el
  /// presupuesto está sin usar.
  Future<_BudgetTotals> _loadBudget(Transaction tx) async {
    final snapshot = await tx.get(_budgetRef);
    final data = snapshot.data();
    final reserved = (data?['reserved'] as num?)?.toInt() ?? 0;
    final spent = (data?['spent'] as num?)?.toInt() ?? 0;
    return _BudgetTotals(reserved: reserved, spent: spent);
  }

  void _saveBudget(
    Transaction tx, {
    required int reserved,
    required int spent,
  }) {
    tx.set(_budgetRef, {'reserved': reserved, 'spent': spent});
  }

  /// Devuelve al presupuesto lo que tenía reservado la actividad cancelada.
  /// [budget] es el documento ya leído (la lectura va antes de cualquier
  /// escritura de la transacción).
  void _returnReservation(
    Transaction tx,
    DocumentSnapshot<Map<String, dynamic>> budget,
    int reservedCost,
  ) {
    if (!budget.exists || reservedCost <= 0) return;

    final reserved = (budget.data()?['reserved'] as num?)?.toInt() ?? 0;
    tx.update(_budgetRef, {'reserved': max(0, reserved - reservedCost)});
  }

  // ---------------------------------------------------------------------
  // Operaciones públicas (usan todo lo de arriba)
  // ---------------------------------------------------------------------

  /// Sube una propuesta guardada en el celular.
  /// No pisa lo que otro rol ya decidió ni la propuesta de otra persona.
  Future<void> pushProposal(ItineraryActivity activity) {
    return _guard(
      () => firestore.runTransaction<void>((tx) async {
        final ref = _activityRef(activity.id);
        final snapshot = await tx.get(ref);
        _checkRemoteProposal(snapshot.data(), activity);
        tx.set(ref, activity.toJson());
      }),
    );
  }

  /// Trae todas las actividades directamente del servidor (no de la caché).
  /// Si no hay conexión falla a propósito: el repositorio usa entonces Drift.
  Future<List<ItineraryActivity>> fetchAll() {
    return _guard(() async {
      final snapshot = await firestore
          .collection('activities')
          .get(const GetOptions(source: Source.server));
      return _parseActivities(snapshot);
    });
  }

  /// Coordinador: aprueba el horario y ocupa la franja.
  Future<ItineraryActivity> approveSchedule({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      _checkAction(ActivityAction.approveSchedule, role, uid, current);

      final slotId = await _reserveSlot(tx, current);

      return _apply(tx, current, {
        'status': ActivityStatus.scheduleApproved.value,
        'slot_id': slotId,
        'return_requested': false,
        'reason': '',
      });
    });
  }

  /// Coordinador: rechaza una propuesta con un motivo.
  Future<ItineraryActivity> rejectProposal({
    required String activityId,
    required String uid,
    required UserRole role,
    required String reason,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      _checkAction(ActivityAction.reject, role, uid, current);
      final reasonText = _validReason(reason);

      return _apply(tx, current, {
        'status': ActivityStatus.rejected.value,
        'reason': reasonText,
      });
    });
  }

  /// Miembro: pide que le devuelvan la actividad a propuesta para corregirla.
  Future<ItineraryActivity> requestReturn({
    required String activityId,
    required String uid,
    required UserRole role,
    required String reason,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      _checkAction(ActivityAction.requestReturn, role, uid, current);
      final reasonText = _validReason(reason);

      return _apply(tx, current, {
        'return_requested': true,
        'reason': reasonText,
      });
    });
  }

  /// Responsable de presupuesto: devuelve la actividad a propuesta, con
  /// motivo, y libera la franja.
  Future<ItineraryActivity> returnToProposal({
    required String activityId,
    required String uid,
    required UserRole role,
    required String reason,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      _checkAction(ActivityAction.returnToProposal, role, uid, current);
      final reasonText = _validReason(reason);

      final slotRef = _slotRef(TripConfig.slotId(current.startAt));
      final slot = await tx.get(slotRef);
      _releaseSlotIfOwned(tx, slotRef, slot, current.id);

      return _apply(tx, current, {
        'status': ActivityStatus.proposed.value,
        'slot_id': '',
        'return_requested': false,
        'reason': reasonText,
      });
    });
  }

  /// Responsable de presupuesto: aprueba el costo y reserva presupuesto.
  Future<ItineraryActivity> approveCost({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      final budget = await _loadBudget(tx);
      _checkAction(ActivityAction.approveCost, role, uid, current);

      final cost = current.estimatedCost;
      _ensure(
        ItineraryRules.checkReserve(
          reserved: budget.reserved,
          spent: budget.spent,
          cost: cost,
        ),
      );
      _saveBudget(tx, reserved: budget.reserved + cost, spent: budget.spent);

      return _apply(tx, current, {
        'status': ActivityStatus.confirmed.value,
        'reserved_cost': cost,
      });
    });
  }

  /// Coordinador: cancela una actividad confirmada y libera la franja y la
  /// reserva de presupuesto.
  Future<ItineraryActivity> cancelActivity({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);

      // Firestore exige leer todo antes de escribir, por eso se lee primero.
      final slotRef = _slotRef(TripConfig.slotId(current.startAt));
      final slot = await tx.get(slotRef);
      final budget = await tx.get(_budgetRef);

      _checkAction(ActivityAction.cancel, role, uid, current);

      _releaseSlotIfOwned(tx, slotRef, slot, current.id);
      _returnReservation(tx, budget, current.reservedCost);

      return _apply(tx, current, {
        'status': ActivityStatus.cancelled.value,
        'slot_id': '',
        'reserved_cost': 0,
      });
    });
  }

  /// Coordinador: marca la actividad como realizada.
  Future<ItineraryActivity> markDone({
    required String activityId,
    required String uid,
    required UserRole role,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      _checkAction(ActivityAction.markDone, role, uid, current);

      return _apply(tx, current, {'status': ActivityStatus.done.value});
    });
  }

  /// Responsable de presupuesto: cierra el costo real. La reserva se cambia
  /// por el gasto real, así el gasto no se cuenta dos veces.
  Future<ItineraryActivity> closeCost({
    required String activityId,
    required String uid,
    required UserRole role,
    required int realCost,
  }) {
    return _inTransaction((tx) async {
      final current = await _load(tx, activityId);
      final budget = await _loadBudget(tx);
      _checkAction(ActivityAction.closeCost, role, uid, current);

      _ensure(
        ItineraryRules.checkCloseCost(
          activity: current,
          realCost: realCost,
          reserved: budget.reserved,
          spent: budget.spent,
        ),
      );
      _saveBudget(
        tx,
        reserved: max(0, budget.reserved - current.reservedCost),
        spent: budget.spent + realCost,
      );

      return _apply(tx, current, {
        'status': ActivityStatus.costClosed.value,
        'real_cost': realCost,
        'reserved_cost': 0,
      });
    });
  }
}
