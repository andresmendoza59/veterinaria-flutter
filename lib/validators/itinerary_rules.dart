import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';

enum ActivityAction {
  edit,
  requestReturn,
  approveSchedule,
  reject,
  returnToProposal,
  approveCost,
  cancel,
  markDone,
  closeCost,
}

class BudgetSummary {
  final int total;
  final int reserved;
  final int spent;
  final int confirmedCount;
  final int doneCount;
  final int closedCount;
  final int cancelledCount;

  const BudgetSummary({
    required this.total,
    required this.reserved,
    required this.spent,
    required this.confirmedCount,
    required this.doneCount,
    required this.closedCount,
    required this.cancelledCount,
  });

  int get available => total - reserved - spent;
}

class ItineraryRules {
  ItineraryRules._();

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  static String? validateWindow({
    required DateTime startAt,
    required DateTime endAt,
  }) {
    if (endAt.isBefore(startAt)) {
      return 'La hora de fin no puede ser anterior al inicio';
    }
    final tripStart = DateTime(
      TripConfig.startDate.year,
      TripConfig.startDate.month,
      TripConfig.startDate.day,
    );
    final tripEnd = DateTime(
      TripConfig.endDate.year,
      TripConfig.endDate.month,
      TripConfig.endDate.day + 1,
    );
    if (startAt.isBefore(tripStart) ||
        !startAt.isBefore(tripEnd) ||
        endAt.isAfter(tripEnd)) {
      return 'La actividad debe estar dentro de las fechas del viaje '
          '(${Fmt.date(TripConfig.startDate)} a ${Fmt.date(TripConfig.endDate)})';
    }
    final aligned = startAt.minute == 0 &&
        startAt.second == 0 &&
        startAt.millisecond == 0 &&
        startAt.microsecond == 0 &&
        TripConfig.slotStartHours.contains(startAt.hour) &&
        endAt.isAtSameMomentAs(TripConfig.slotEnd(startAt));
    if (!aligned) {
      return 'Debe coincidir con una franja de 2 horas '
          '(08:00, 10:00, 12:00, 14:00, 16:00 o 18:00)';
    }
    return null;
  }

  static String? validateCostText(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa un valor';
    if (!_digitsOnly.hasMatch(text)) {
      return 'Solo números, sin puntos ni signos';
    }
    final value = int.tryParse(text);
    if (value == null || value > TripConfig.totalBudget) {
      return 'El valor supera el presupuesto del viaje';
    }
    return null;
  }

  static String? validateReason(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Escribe un motivo';
    if (text.length > 200) return 'El motivo no puede superar los 200 caracteres';
    return null;
  }

  static int? parseCost(String? raw) {
    final text = raw?.trim() ?? '';
    if (!_digitsOnly.hasMatch(text)) return null;
    return int.tryParse(text);
  }

  static String? checkAction({
    required ActivityAction action,
    required UserRole role,
    required String uid,
    required ItineraryActivity activity,
    required DateTime now,
  }) {
    final requiredRole = _requiredRole(action);
    if (requiredRole != null && role != requiredRole) {
      return 'Tu rol no permite esta acción';
    }
    if (_requiresOwner(action) && activity.ownerUid != uid) {
      return 'Solo quien propuso la actividad puede hacerlo';
    }
    if (activity.status != _requiredStatus(action)) {
      return _stateMessage(activity);
    }
    if (action == ActivityAction.requestReturn && activity.returnRequested) {
      return 'Ya solicitaste la devolución';
    }
    if (action == ActivityAction.cancel && !now.isBefore(activity.startAt)) {
      return 'No se puede cancelar una actividad que ya inició';
    }
    return null;
  }

  static bool can({
    required ActivityAction action,
    required UserRole role,
    required String uid,
    required ItineraryActivity activity,
    required DateTime now,
  }) {
    return checkAction(
          action: action,
          role: role,
          uid: uid,
          activity: activity,
          now: now,
        ) ==
        null;
  }

  static ActivityStatus nextStatus(ActivityAction action) {
    switch (action) {
      case ActivityAction.edit:
        return ActivityStatus.proposed;
      case ActivityAction.requestReturn:
        return ActivityStatus.scheduleApproved;
      case ActivityAction.approveSchedule:
        return ActivityStatus.scheduleApproved;
      case ActivityAction.reject:
        return ActivityStatus.rejected;
      case ActivityAction.returnToProposal:
        return ActivityStatus.proposed;
      case ActivityAction.approveCost:
        return ActivityStatus.confirmed;
      case ActivityAction.cancel:
        return ActivityStatus.cancelled;
      case ActivityAction.markDone:
        return ActivityStatus.done;
      case ActivityAction.closeCost:
        return ActivityStatus.costClosed;
    }
  }

  static int available({required int reserved, required int spent}) {
    return TripConfig.totalBudget - reserved - spent;
  }

  static String? checkReserve({
    required int reserved,
    required int spent,
    required int cost,
  }) {
    if (reserved + spent + cost > TripConfig.totalBudget) {
      final free = available(reserved: reserved, spent: spent);
      return 'Presupuesto excedido: el costo previsto (${Fmt.money(cost)}) '
          'supera el saldo disponible (${Fmt.money(free)})';
    }
    return null;
  }

  static String? checkCloseCost({
    required ItineraryActivity activity,
    required int realCost,
    required int reserved,
    required int spent,
  }) {
    if (activity.status != ActivityStatus.done) {
      return _stateMessage(activity);
    }
    if (realCost < 0) return 'El costo real no puede ser negativo';
    final diff = realCost - activity.reservedCost;
    if (diff > 0 && diff > available(reserved: reserved, spent: spent)) {
      return 'Saldo insuficiente para cubrir la diferencia de '
          '${Fmt.money(diff)} del costo real';
    }
    return null;
  }

  static BudgetSummary summarize(Iterable<ItineraryActivity> items) {
    var reserved = 0;
    var spent = 0;
    var confirmedCount = 0;
    var doneCount = 0;
    var closedCount = 0;
    var cancelledCount = 0;
    for (final item in items) {
      switch (item.status) {
        case ActivityStatus.confirmed:
          reserved += item.reservedCost;
          confirmedCount++;
        case ActivityStatus.done:
          reserved += item.reservedCost;
          doneCount++;
        case ActivityStatus.costClosed:
          spent += item.realCost;
          closedCount++;
        case ActivityStatus.cancelled:
          cancelledCount++;
        case ActivityStatus.proposed:
        case ActivityStatus.scheduleApproved:
        case ActivityStatus.rejected:
          break;
      }
    }
    return BudgetSummary(
      total: TripConfig.totalBudget,
      reserved: reserved,
      spent: spent,
      confirmedCount: confirmedCount,
      doneCount: doneCount,
      closedCount: closedCount,
      cancelledCount: cancelledCount,
    );
  }

  static UserRole? _requiredRole(ActivityAction action) {
    switch (action) {
      case ActivityAction.edit:
      case ActivityAction.requestReturn:
        return null;
      case ActivityAction.approveSchedule:
      case ActivityAction.reject:
      case ActivityAction.cancel:
      case ActivityAction.markDone:
        return UserRole.coordinator;
      case ActivityAction.returnToProposal:
      case ActivityAction.approveCost:
      case ActivityAction.closeCost:
        return UserRole.finance;
    }
  }

  static bool _requiresOwner(ActivityAction action) {
    return action == ActivityAction.edit ||
        action == ActivityAction.requestReturn;
  }

  static ActivityStatus _requiredStatus(ActivityAction action) {
    switch (action) {
      case ActivityAction.edit:
      case ActivityAction.approveSchedule:
      case ActivityAction.reject:
        return ActivityStatus.proposed;
      case ActivityAction.requestReturn:
      case ActivityAction.returnToProposal:
      case ActivityAction.approveCost:
        return ActivityStatus.scheduleApproved;
      case ActivityAction.cancel:
      case ActivityAction.markDone:
        return ActivityStatus.confirmed;
      case ActivityAction.closeCost:
        return ActivityStatus.done;
    }
  }

  static String _stateMessage(ItineraryActivity activity) {
    return 'La actividad ya no está disponible para esta acción '
        '(estado: ${activity.status.label})';
  }
}
