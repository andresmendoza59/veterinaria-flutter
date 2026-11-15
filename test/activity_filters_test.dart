import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/validators/activity_filters.dart';
import 'package:flutter_test/flutter_test.dart';

// Crea una actividad de prueba cambiando solo lo que importa en cada caso.
ItineraryActivity _activity({
  required String id,
  required ActivityStatus status,
  String ownerUid = 'miembro-1',
  String category = 'Aventura',
  int day = 1,
  bool pendingSync = false,
}) {
  final start = DateTime(2027, 2, day, 8);
  return ItineraryActivity(
    id: id,
    ownerUid: ownerUid,
    catalogId: 'cat-01',
    title: 'Actividad $id',
    category: category,
    location: 'Salento',
    startAt: start,
    endAt: start.add(const Duration(hours: 2)),
    estimatedCost: 100000,
    status: status,
    slotId: '',
    reservedCost: 0,
    realCost: 0,
    reason: '',
    returnRequested: false,
    updatedAt: DateTime(2027, 1, 1),
    pendingSync: pendingSync,
    syncError: '',
  );
}

List<String> _ids(List<ItineraryActivity> items) {
  final result = <String>[];
  for (final item in items) {
    result.add(item.id);
  }
  return result;
}

void main() {
  final all = [
    _activity(id: 'p1', status: ActivityStatus.proposed),
    _activity(id: 'h1', status: ActivityStatus.scheduleApproved),
    _activity(id: 'c1', status: ActivityStatus.confirmed, category: 'Cultura'),
    _activity(id: 'd1', status: ActivityStatus.done, day: 2),
    _activity(id: 'k1', status: ActivityStatus.costClosed, day: 3),
    _activity(id: 'x1', status: ActivityStatus.cancelled, category: 'Cultura'),
    _activity(id: 'r1', status: ActivityStatus.rejected),
  ];

  test('cambio de cuenta: no se ven pendientes de otra persona', () {
    final items = [
      _activity(id: 'mio', status: ActivityStatus.proposed, pendingSync: true),
      _activity(
        id: 'ajeno',
        status: ActivityStatus.proposed,
        ownerUid: 'otra-cuenta',
        pendingSync: true,
      ),
      _activity(
        id: 'compartido',
        status: ActivityStatus.confirmed,
        ownerUid: 'otra-cuenta',
      ),
    ];

    final visible = ActivityFilters.visibleFor(items, 'miembro-1');

    expect(_ids(visible), ['mio', 'compartido']);
  });

  test('una propuesta pendiente nunca llega a las vistas de revisión', () {
    final items = [
      _activity(
        id: 'pendiente',
        status: ActivityStatus.proposed,
        pendingSync: true,
      ),
      _activity(id: 'enviada', status: ActivityStatus.proposed),
    ];

    expect(_ids(ActivityFilters.forCoordinator(items)), ['enviada']);
  });

  test('cada rol ve solo los estados sobre los que puede decidir', () {
    expect(_ids(ActivityFilters.forCoordinator(all)), ['p1', 'c1']);
    expect(_ids(ActivityFilters.forFinance(all)), ['h1', 'd1']);
  });

  test('el itinerario muestra solo lo que ocupa una franja', () {
    expect(_ids(ActivityFilters.forItinerary(all)), ['h1', 'c1', 'd1', 'k1']);
  });

  test(
    'el balance distingue confirmadas, realizadas, cerradas y canceladas',
    () {
      final balance = ActivityFilters.forBalance(all);

      expect(_ids(balance), ['c1', 'd1', 'k1', 'x1']);
      expect(
        _ids(ActivityFilters.byStatus(balance, ActivityStatus.cancelled)),
        ['x1'],
      );
      expect(
        _ids(ActivityFilters.byStatus(balance, ActivityStatus.costClosed)),
        ['k1'],
      );
    },
  );

  test('filtros por categoría y por día; null significa "todos"', () {
    final balance = ActivityFilters.forBalance(all);

    expect(_ids(ActivityFilters.byCategory(balance, 'Cultura')), ['c1', 'x1']);
    expect(ActivityFilters.byCategory(balance, null).length, 4);
    expect(_ids(ActivityFilters.byDay(balance, DateTime(2027, 2, 2))), ['d1']);
    expect(ActivityFilters.byDay(balance, null).length, 4);
  });

  test('categoriesOf devuelve categorías únicas en orden', () {
    expect(ActivityFilters.categoriesOf(all), ['Aventura', 'Cultura']);
  });

  test(
    'activityAt encuentra la actividad de una franja o null si está libre',
    () {
      final itinerary = ActivityFilters.forItinerary(all);

      final busy = ActivityFilters.activityAt(
        itinerary,
        DateTime(2027, 2, 2, 8),
      );
      final free = ActivityFilters.activityAt(
        itinerary,
        DateTime(2027, 2, 2, 10),
      );

      expect(busy?.id, 'd1');
      expect(free, isNull);
    },
  );
}
