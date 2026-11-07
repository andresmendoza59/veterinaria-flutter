import 'package:flutter_app/core/trip_config.dart';

class Fmt {
  Fmt._();

  static final RegExp _thousands = RegExp(r'\B(?=(\d{3})+(?!\d))');

  static String two(int v) => v.toString().padLeft(2, '0');

  static String date(DateTime d) {
    final local = d.toLocal();
    return '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  static String dateTime(DateTime d) {
    final local = d.toLocal();
    return '${date(local)} ${time(local)}';
  }

  static String time(DateTime d) {
    final local = d.toLocal();
    return '${two(local.hour)}:${two(local.minute)}';
  }

  static String slotLabel(DateTime start) {
    return '${time(start)} - ${time(TripConfig.slotEnd(start))}';
  }

  static String isoDay(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  static String money(int v) {
    final digits = v.abs().toString().replaceAllMapped(_thousands, (_) => '.');
    return v < 0 ? '-\$ $digits' : '\$ $digits';
  }
}
