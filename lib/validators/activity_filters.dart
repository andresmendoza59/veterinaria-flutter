import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';

/// Filtros puros sobre listas de actividades.
/// No tocan Drift ni Firestore: reciben una lista y devuelven otra.
/// Por eso se pueden probar con flutter_test sin Firebase.
class ActivityFilters {
  ActivityFilters._();

  /// Lo que puede ver un usuario en las vistas compartidas: todo lo que ya
  /// está sincronizado (el viaje es de todos) y, de lo pendiente, solo lo suyo.
  /// Así, al cambiar de cuenta no se mezclan pendientes de otra persona.
  static List<ItineraryActivity> visibleFor(
    List<ItineraryActivity> items,
    String uid,
  ) {
    final result = <ItineraryActivity>[];
    for (final item in items) {
      final isMine = item.ownerUid == uid;
      if (!item.pendingSync || isMine) {
        result.add(item);
      }
    }
    return result;
  }

  /// Solo lo confirmado por el servidor. Una operación pendiente nunca se
  /// muestra como aprobada ni cuenta en el presupuesto.
  static List<ItineraryActivity> onlySynced(List<ItineraryActivity> items) {
    final result = <ItineraryActivity>[];
    for (final item in items) {
      if (!item.pendingSync) {
        result.add(item);
      }
    }
    return result;
  }

  static List<ItineraryActivity> withStatuses(
    List<ItineraryActivity> items,
    Set<ActivityStatus> statuses,
  ) {
    final result = <ItineraryActivity>[];
    for (final item in onlySynced(items)) {
      if (statuses.contains(item.status)) {
        result.add(item);
      }
    }
    return result;
  }

  /// Coordinador: propuestas por aprobar o rechazar y confirmadas por
  /// marcar como realizadas o cancelar.
  static List<ItineraryActivity> forCoordinator(List<ItineraryActivity> items) {
    return withStatuses(items, {
      ActivityStatus.proposed,
      ActivityStatus.confirmed,
    });
  }

  /// Responsable de presupuesto: horarios aprobados (aprobar o devolver el
  /// costo) y realizadas (cerrar el costo real).
  static List<ItineraryActivity> forFinance(List<ItineraryActivity> items) {
    return withStatuses(items, {
      ActivityStatus.scheduleApproved,
      ActivityStatus.done,
    });
  }

  /// Itinerario: actividades que ocupan una franja.
  static List<ItineraryActivity> forItinerary(List<ItineraryActivity> items) {
    return withStatuses(items, {
      ActivityStatus.scheduleApproved,
      ActivityStatus.confirmed,
      ActivityStatus.done,
      ActivityStatus.costClosed,
    });
  }

  /// Balance: actividades que tienen o tuvieron que ver con dinero.
  static List<ItineraryActivity> forBalance(List<ItineraryActivity> items) {
    return withStatuses(items, {
      ActivityStatus.confirmed,
      ActivityStatus.done,
      ActivityStatus.costClosed,
      ActivityStatus.cancelled,
    });
  }

  /// Si category es null no se filtra (significa "Todas").
  static List<ItineraryActivity> byCategory(
    List<ItineraryActivity> items,
    String? category,
  ) {
    if (category == null) return items;
    final result = <ItineraryActivity>[];
    for (final item in items) {
      if (item.category == category) {
        result.add(item);
      }
    }
    return result;
  }

  /// Si day es null no se filtra (significa "Todos los días").
  static List<ItineraryActivity> byDay(
    List<ItineraryActivity> items,
    DateTime? day,
  ) {
    if (day == null) return items;
    final result = <ItineraryActivity>[];
    for (final item in items) {
      if (isSameDay(item.startAt, day)) {
        result.add(item);
      }
    }
    return result;
  }

  /// Si status es null no se filtra (significa "Todos los estados").
  static List<ItineraryActivity> byStatus(
    List<ItineraryActivity> items,
    ActivityStatus? status,
  ) {
    if (status == null) return items;
    final result = <ItineraryActivity>[];
    for (final item in items) {
      if (item.status == status) {
        result.add(item);
      }
    }
    return result;
  }

  /// Categorías únicas presentes en la lista, en orden alfabético.
  static List<String> categoriesOf(List<ItineraryActivity> items) {
    final categories = <String>{};
    for (final item in items) {
      categories.add(item.category);
    }
    final result = categories.toList();
    result.sort();
    return result;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
