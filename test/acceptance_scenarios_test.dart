import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';
import 'package:flutter_test/flutter_test.dart';

// Pruebas de la parte pura de los escenarios de aceptación del enunciado.
// La parte concurrente (dos teléfonos a la vez) la garantiza la transacción
// de Firestore y se prueba a mano (ver docs/matriz_pruebas.md).

ItineraryActivity _activity({
  required String id,
  required ActivityStatus status,
  int reservedCost = 0,
  int realCost = 0,
}) {
  final start = DateTime(2027, 2, 2, 10);
  return ItineraryActivity(
    id: id,
    ownerUid: 'miembro-1',
    catalogId: 'cat-01',
    title: 'Actividad $id',
    category: 'Aventura',
    location: 'Salento',
    startAt: start,
    endAt: TripConfig.slotEnd(start),
    estimatedCost: reservedCost,
    status: status,
    slotId: TripConfig.slotId(start),
    reservedCost: reservedCost,
    realCost: realCost,
    reason: '',
    returnRequested: false,
    updatedAt: DateTime(2027, 1, 1),
    pendingSync: false,
    syncError: '',
  );
}

void main() {
  test(
    'escenario 2: la segunda confirmación no puede exceder el presupuesto',
    () {
      // Dentro de la transacción, la segunda confirmación ya ve la reserva de la
      // primera. Aquí se simula ese orden con los mismos números.
      const firstCost = 1200000;
      const secondCost = 1200000;

      final firstCheck = ItineraryRules.checkReserve(
        reserved: 0,
        spent: 0,
        cost: firstCost,
      );
      final secondCheck = ItineraryRules.checkReserve(
        reserved: firstCost,
        spent: 0,
        cost: secondCost,
      );

      expect(firstCheck, isNull);
      expect(secondCheck, startsWith('Presupuesto excedido'));
    },
  );

  test('escenario 3a: cancelar devuelve el saldo reservado', () {
    final before = ItineraryRules.summarize([
      _activity(
        id: 'a',
        status: ActivityStatus.confirmed,
        reservedCost: 300000,
      ),
    ]);
    // La transacción de cancelar pone reserved_cost en 0 y estado CANCELADA.
    final after = ItineraryRules.summarize([
      _activity(id: 'a', status: ActivityStatus.cancelled),
    ]);

    expect(before.available, 1700000);
    expect(after.available, TripConfig.totalBudget);
    expect(after.cancelledCount, 1);
  });

  test(
    'escenario 3b: cerrar costo cambia la reserva por el gasto sin duplicar',
    () {
      final before = ItineraryRules.summarize([
        _activity(id: 'a', status: ActivityStatus.done, reservedCost: 300000),
      ]);
      // La transacción de cerrar costo pone reserved_cost en 0 y real_cost en
      // el valor real.
      final after = ItineraryRules.summarize([
        _activity(id: 'a', status: ActivityStatus.costClosed, realCost: 280000),
      ]);

      expect(before.reserved, 300000);
      expect(before.spent, 0);
      expect(after.reserved, 0);
      expect(after.spent, 280000);
      expect(after.available, TripConfig.totalBudget - 280000);
    },
  );

  test('escenario 3c: cancelar no devuelve gastos ya cerrados', () {
    final summary = ItineraryRules.summarize([
      _activity(
        id: 'cerrada',
        status: ActivityStatus.costClosed,
        realCost: 500000,
      ),
      _activity(id: 'cancelada', status: ActivityStatus.cancelled),
    ]);

    expect(summary.spent, 500000);
    expect(summary.available, 1500000);
  });
}
