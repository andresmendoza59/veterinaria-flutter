enum ActivityStatus {
  proposed('PROPUESTA'),
  scheduleApproved('HORARIO_APROBADO'),
  confirmed('CONFIRMADA'),
  done('REALIZADA'),
  costClosed('COSTO_CERRADO'),
  rejected('RECHAZADA'),
  cancelled('CANCELADA');

  final String value;

  const ActivityStatus(this.value);

  static ActivityStatus fromValue(String value) {
    for (final status in ActivityStatus.values) {
      if (status.value == value) return status;
    }
    throw FormatException('Estado desconocido: $value');
  }

  String get label {
    switch (this) {
      case ActivityStatus.proposed:
        return 'Propuesta';
      case ActivityStatus.scheduleApproved:
        return 'Horario aprobado';
      case ActivityStatus.confirmed:
        return 'Confirmada';
      case ActivityStatus.done:
        return 'Realizada';
      case ActivityStatus.costClosed:
        return 'Costo cerrado';
      case ActivityStatus.rejected:
        return 'Rechazada';
      case ActivityStatus.cancelled:
        return 'Cancelada';
    }
  }

  bool get occupiesSlot =>
      this == ActivityStatus.scheduleApproved ||
      this == ActivityStatus.confirmed ||
      this == ActivityStatus.done ||
      this == ActivityStatus.costClosed;

  bool get isTerminal =>
      this == ActivityStatus.costClosed ||
      this == ActivityStatus.rejected ||
      this == ActivityStatus.cancelled;
}
