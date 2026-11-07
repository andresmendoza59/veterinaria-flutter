import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final ItineraryActivity _base = ItineraryActivity(
  id: 'u1_1',
  ownerUid: 'u1',
  catalogId: 'cat-01',
  title: 'Paseo en cafetal',
  category: 'Aventura',
  location: 'Salento',
  startAt: DateTime(2027, 2, 1, 8),
  endAt: DateTime(2027, 2, 1, 10),
  estimatedCost: 100000,
  status: ActivityStatus.proposed,
  slotId: '',
  reservedCost: 0,
  realCost: 0,
  reason: '',
  returnRequested: false,
  updatedAt: DateTime(2027, 1, 1),
  pendingSync: true,
  syncError: '',
);

bool _allowed(
  ActivityAction action,
  UserRole role,
  ItineraryActivity activity, {
  String uid = 'u1',
  DateTime? now,
}) {
  return ItineraryRules.can(
    action: action,
    role: role,
    uid: uid,
    activity: activity,
    now: now ?? DateTime(2027, 1, 15),
  );
}

void main() {
  test('slotId usa el formato yyyyMMdd_HH', () {
    expect(TripConfig.slotId(DateTime(2027, 2, 1, 8)), '20270201_08');
    expect(TripConfig.slotId(DateTime(2027, 2, 5, 18)), '20270205_18');
  });

  test('el viaje tiene cinco dias inclusivos', () {
    final days = TripConfig.days;
    expect(days.length, 5);
    expect(days.first, DateTime(2027, 2, 1));
    expect(days.last, DateTime(2027, 2, 5));
    expect(TripConfig.isTripDay(DateTime(2027, 2, 5, 23)), isTrue);
    expect(TripConfig.isTripDay(DateTime(2027, 2, 6)), isFalse);
  });

  test('los estados persistidos coinciden con la especificacion', () {
    expect(ActivityStatus.values.map((s) => s.value).toList(), [
      'PROPUESTA',
      'HORARIO_APROBADO',
      'CONFIRMADA',
      'REALIZADA',
      'COSTO_CERRADO',
      'RECHAZADA',
      'CANCELADA',
    ]);
    expect(ActivityStatus.fromValue('CONFIRMADA'), ActivityStatus.confirmed);
    expect(() => ActivityStatus.fromValue('X'), throwsFormatException);
  });

  test('R1 acepta una franja valida y rechaza fin anterior al inicio', () {
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 1, 8),
        endAt: DateTime(2027, 2, 1, 10),
      ),
      isNull,
    );
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 1, 10),
        endAt: DateTime(2027, 2, 1, 8),
      ),
      isNotNull,
    );
  });

  test('R1 rechaza dias fuera del viaje', () {
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 1, 31, 18),
        endAt: DateTime(2027, 1, 31, 20),
      ),
      isNotNull,
    );
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 6, 8),
        endAt: DateTime(2027, 2, 6, 10),
      ),
      isNotNull,
    );
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 5, 18),
        endAt: DateTime(2027, 2, 5, 20),
      ),
      isNull,
    );
  });

  test('R1 rechaza horas que no son una franja de dos horas', () {
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 2, 9),
        endAt: DateTime(2027, 2, 2, 11),
      ),
      isNotNull,
    );
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 2, 8, 30),
        endAt: DateTime(2027, 2, 2, 10, 30),
      ),
      isNotNull,
    );
    expect(
      ItineraryRules.validateWindow(
        startAt: DateTime(2027, 2, 2, 8),
        endAt: DateTime(2027, 2, 2, 11),
      ),
      isNotNull,
    );
  });

  test('validadores de costo y motivo', () {
    expect(ItineraryRules.validateCostText(''), 'Ingresa un valor');
    expect(ItineraryRules.validateCostText('12a'), isNotNull);
    expect(ItineraryRules.validateCostText('-5'), isNotNull);
    expect(ItineraryRules.validateCostText('2000000'), isNull);
    expect(ItineraryRules.validateCostText('2000001'), isNotNull);
    expect(ItineraryRules.parseCost(' 450000 '), 450000);
    expect(ItineraryRules.parseCost('4.5'), isNull);
    expect(ItineraryRules.validateReason('   '), 'Escribe un motivo');
    expect(ItineraryRules.validateReason('x' * 201), isNotNull);
    expect(ItineraryRules.validateReason('ok'), isNull);
  });

  test('un miembro no aprueba horario y el coordinador no aprueba costo', () {
    expect(_allowed(ActivityAction.approveSchedule, UserRole.member, _base),
        isFalse);
    expect(
        _allowed(ActivityAction.approveSchedule, UserRole.coordinator, _base),
        isTrue);
    final approved = _base.copyWith(status: ActivityStatus.scheduleApproved);
    expect(_allowed(ActivityAction.approveCost, UserRole.coordinator, approved),
        isFalse);
    expect(_allowed(ActivityAction.approveCost, UserRole.finance, approved),
        isTrue);
    expect(_allowed(ActivityAction.returnToProposal, UserRole.finance, approved),
        isTrue);
  });

  test('R4 editar exige ser el dueno y estado PROPUESTA', () {
    expect(_allowed(ActivityAction.edit, UserRole.member, _base), isTrue);
    expect(_allowed(ActivityAction.edit, UserRole.member, _base, uid: 'u2'),
        isFalse);
    final approved = _base.copyWith(status: ActivityStatus.scheduleApproved);
    expect(_allowed(ActivityAction.edit, UserRole.member, approved), isFalse);
  });

  test('solicitar devolucion solo una vez y solo con horario aprobado', () {
    final approved = _base.copyWith(status: ActivityStatus.scheduleApproved);
    expect(_allowed(ActivityAction.requestReturn, UserRole.member, approved),
        isTrue);
    expect(_allowed(ActivityAction.requestReturn, UserRole.member, _base),
        isFalse);
    expect(
        _allowed(ActivityAction.requestReturn, UserRole.member, approved,
            uid: 'u2'),
        isFalse);
    final requested = approved.copyWith(returnRequested: true);
    expect(_allowed(ActivityAction.requestReturn, UserRole.member, requested),
        isFalse);
  });

  test('cancelar solo antes del inicio y estando confirmada', () {
    final confirmed = _base.copyWith(status: ActivityStatus.confirmed);
    expect(_allowed(ActivityAction.cancel, UserRole.coordinator, confirmed),
        isTrue);
    expect(
        _allowed(ActivityAction.cancel, UserRole.coordinator, confirmed,
            now: DateTime(2027, 2, 1, 8)),
        isFalse);
    expect(
        _allowed(ActivityAction.cancel, UserRole.coordinator, confirmed,
            now: DateTime(2027, 2, 2)),
        isFalse);
    expect(_allowed(ActivityAction.cancel, UserRole.coordinator, _base),
        isFalse);
  });

  test('marcar realizada y cerrar costo siguen el flujo', () {
    final confirmed = _base.copyWith(status: ActivityStatus.confirmed);
    final done = _base.copyWith(status: ActivityStatus.done);
    expect(_allowed(ActivityAction.markDone, UserRole.coordinator, confirmed),
        isTrue);
    expect(_allowed(ActivityAction.markDone, UserRole.coordinator, done),
        isFalse);
    expect(_allowed(ActivityAction.closeCost, UserRole.finance, done), isTrue);
    expect(_allowed(ActivityAction.closeCost, UserRole.finance, confirmed),
        isFalse);
    expect(_allowed(ActivityAction.reject, UserRole.coordinator, _base),
        isTrue);
  });

  test('nextStatus coincide con la tabla de transiciones', () {
    expect(ItineraryRules.nextStatus(ActivityAction.approveSchedule),
        ActivityStatus.scheduleApproved);
    expect(ItineraryRules.nextStatus(ActivityAction.approveCost),
        ActivityStatus.confirmed);
    expect(ItineraryRules.nextStatus(ActivityAction.returnToProposal),
        ActivityStatus.proposed);
    expect(ItineraryRules.nextStatus(ActivityAction.cancel),
        ActivityStatus.cancelled);
    expect(ItineraryRules.nextStatus(ActivityAction.markDone),
        ActivityStatus.done);
    expect(ItineraryRules.nextStatus(ActivityAction.closeCost),
        ActivityStatus.costClosed);
    expect(ItineraryRules.nextStatus(ActivityAction.reject),
        ActivityStatus.rejected);
  });

  test('R3 permite exactamente el presupuesto total y rechaza un peso mas', () {
    expect(
        ItineraryRules.checkReserve(reserved: 1200000, spent: 500000, cost: 300000),
        isNull);
    expect(
        ItineraryRules.checkReserve(reserved: 1200000, spent: 500000, cost: 300001),
        isNotNull);
    expect(ItineraryRules.available(reserved: 1200000, spent: 500000), 300000);
  });

  test('R5 exige REALIZADA, valor no negativo y saldo para la diferencia', () {
    final done = _base.copyWith(
      status: ActivityStatus.done,
      reservedCost: 500000,
    );
    expect(
        ItineraryRules.checkCloseCost(
            activity: done, realCost: 1500000, reserved: 500000, spent: 0),
        isNull);
    expect(
        ItineraryRules.checkCloseCost(
            activity: done, realCost: 600000, reserved: 1900000, spent: 0),
        isNull);
    expect(
        ItineraryRules.checkCloseCost(
            activity: done, realCost: 700000, reserved: 1900000, spent: 0),
        isNotNull);
    expect(
        ItineraryRules.checkCloseCost(
            activity: done, realCost: 100000, reserved: 1900000, spent: 0),
        isNull);
    expect(
        ItineraryRules.checkCloseCost(
            activity: done, realCost: -1, reserved: 500000, spent: 0),
        'El costo real no puede ser negativo');
    expect(
        ItineraryRules.checkCloseCost(
            activity: _base.copyWith(status: ActivityStatus.confirmed),
            realCost: 1,
            reserved: 0,
            spent: 0),
        isNotNull);
  });

  test('summarize separa reservado, gastado y conteos', () {
    final items = [
      _base.copyWith(
          status: ActivityStatus.confirmed, reservedCost: 300000),
      _base.copyWith(status: ActivityStatus.done, reservedCost: 200000),
      _base.copyWith(status: ActivityStatus.costClosed, realCost: 400000),
      _base.copyWith(status: ActivityStatus.cancelled),
      _base.copyWith(status: ActivityStatus.proposed, estimatedCost: 999999),
    ];
    final summary = ItineraryRules.summarize(items);
    expect(summary.total, 2000000);
    expect(summary.reserved, 500000);
    expect(summary.spent, 400000);
    expect(summary.available, 1100000);
    expect(summary.confirmedCount, 1);
    expect(summary.doneCount, 1);
    expect(summary.closedCount, 1);
    expect(summary.cancelledCount, 1);
  });

  test('toJson tiene 16 claves y fromJson lo reconstruye', () {
    final json = _base.toJson();
    expect(json.length, 16);
    expect(json.containsKey('pending_sync'), isFalse);
    expect(json.containsKey('sync_error'), isFalse);
    final back = ItineraryActivity.fromJson(json);
    expect(back.id, _base.id);
    expect(back.startAt, _base.startAt);
    expect(back.status, ActivityStatus.proposed);
    expect(back.pendingSync, isFalse);
    expect(back.syncState, SyncState.synced);
  });

  test('syncState distingue sincronizada, en cola y rechazada', () {
    expect(_base.syncState, SyncState.queued);
    expect(_base.copyWith(syncError: 'x').syncState, SyncState.rejected);
    expect(_base.copyWith(pendingSync: false).syncState, SyncState.synced);
  });

  test('formato de dinero y franjas', () {
    expect(Fmt.money(1250000), '\$ 1.250.000');
    expect(Fmt.money(0), '\$ 0');
    expect(Fmt.money(-1250000), '-\$ 1.250.000');
    expect(Fmt.slotLabel(DateTime(2027, 2, 1, 8)), '08:00 - 10:00');
    expect(Fmt.date(DateTime(2027, 2, 1)), '01/02/2027');
    expect(Fmt.isoDay(DateTime(2027, 2, 1)), '2027-02-01');
  });
}
