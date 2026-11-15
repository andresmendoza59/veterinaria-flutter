import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_card.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_list_view.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/decision_helpers.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/validators/activity_filters.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

/// Vista del coordinador: aprueba o rechaza horarios de propuestas y
/// registra la realización o cancelación de actividades confirmadas.
/// Todas las decisiones se hacen online con transacciones de Firestore.
class ScheduleApprovalScreen extends StatefulWidget {
  final String uid;
  final UserRole role;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const ScheduleApprovalScreen({
    super.key,
    required this.uid,
    required this.role,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  State<ScheduleApprovalScreen> createState() => _ScheduleApprovalScreenState();
}

class _ScheduleApprovalScreenState extends State<ScheduleApprovalScreen> {
  late Future<ActivitiesResult> _future;
  // true mientras una decisión se está enviando a Firestore.
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _future = widget.itineraryRepo.loadShared(uid: widget.uid);
    widget.refresh.addListener(_reload);
  }

  @override
  void dispose() {
    widget.refresh.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = widget.itineraryRepo.loadShared(uid: widget.uid);
    });
  }

  Future<void> _onRefresh() async {
    _reload();
    try {
      await _future;
    } catch (_) {
      return;
    }
  }

  String _slotText(ItineraryActivity activity) {
    return '${Fmt.date(activity.startAt)} ${Fmt.slotLabel(activity.startAt)}';
  }

  Future<void> _approveSchedule(ItineraryActivity activity) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Aprobar horario',
      message:
          '"${activity.title}" ocupará la franja ${_slotText(activity)}. '
          'Si otra actividad ya la ocupó, la aprobación será rechazada.',
      confirmLabel: 'Aprobar',
    );
    if (!mounted) return;
    if (!confirmed) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.approveSchedule(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
      ),
      successMessage: 'Horario aprobado: la franja quedó ocupada',
      refresh: widget.refresh,
    );
  }

  Future<void> _reject(ItineraryActivity activity) async {
    final reason = await reasonDialog(
      context,
      title: 'Rechazar propuesta',
      confirmLabel: 'Rechazar',
    );
    if (!mounted) return;
    if (reason == null) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.rejectProposal(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
        reason: reason,
      ),
      successMessage: 'Propuesta rechazada',
      refresh: widget.refresh,
    );
  }

  Future<void> _markDone(ItineraryActivity activity) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Registrar realización',
      message: '¿Confirmas que "${activity.title}" ya se realizó?',
      confirmLabel: 'Marcar realizada',
    );
    if (!mounted) return;
    if (!confirmed) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.markDone(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
      ),
      successMessage: 'Actividad marcada como realizada',
      refresh: widget.refresh,
    );
  }

  Future<void> _cancel(ItineraryActivity activity) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Cancelar actividad',
      message:
          'Se cancelará "${activity.title}". Se liberan la franja '
          '${_slotText(activity)} y la reserva de '
          '${Fmt.money(activity.reservedCost)}. Esta acción no se puede deshacer.',
      confirmLabel: 'Cancelar actividad',
    );
    if (!mounted) return;
    if (!confirmed) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.cancelActivity(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
      ),
      successMessage: 'Actividad cancelada: franja y presupuesto liberados',
      refresh: widget.refresh,
    );
  }

  /// Ejecuta una decisión con los botones deshabilitados, para que un doble
  /// toque no envíe la misma transacción dos veces.
  Future<void> _runBlocking(Future<void> Function() decision) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await decision();
    } finally {
      // finally: aunque algo falle, los botones vuelven a habilitarse.
      if (mounted) setState(() => _working = false);
    }
  }

  bool _can(ActivityAction action, ItineraryActivity activity) {
    return ItineraryRules.can(
      action: action,
      role: widget.role,
      uid: widget.uid,
      activity: activity,
      now: DateTime.now(),
    );
  }

  List<Widget> _actionsFor(ItineraryActivity activity) {
    final actions = <Widget>[];
    if (_can(ActivityAction.approveSchedule, activity)) {
      actions.add(
        FilledButton.icon(
          onPressed: _working
              ? null
              : () => _runBlocking(() => _approveSchedule(activity)),
          icon: const Icon(Icons.event_available),
          label: const Text('Aprobar horario'),
        ),
      );
    }
    if (_can(ActivityAction.reject, activity)) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _working
              ? null
              : () => _runBlocking(() => _reject(activity)),
          icon: const Icon(Icons.block),
          label: const Text('Rechazar'),
        ),
      );
    }
    if (_can(ActivityAction.markDone, activity)) {
      actions.add(
        FilledButton.icon(
          onPressed: _working
              ? null
              : () => _runBlocking(() => _markDone(activity)),
          icon: const Icon(Icons.task_alt),
          label: const Text('Marcar realizada'),
        ),
      );
    }
    if (_can(ActivityAction.cancel, activity)) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _working
              ? null
              : () => _runBlocking(() => _cancel(activity)),
          icon: const Icon(Icons.event_busy),
          label: const Text('Cancelar'),
        ),
      );
    }
    return actions;
  }

  Widget _buildCard(ItineraryActivity activity) {
    return ActivityCard(
      activity: activity,
      showSync: false,
      actions: _actionsFor(activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivitiesResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: 'No se pudieron cargar las actividades por revisar',
            retryLabel: 'Reintentar',
            onRetry: _reload,
          );
        }

        final result = snapshot.data;
        final all = result?.items ?? [];
        final items = ActivityFilters.forCoordinator(all);

        return ActivityListView(
          items: items,
          fromCache: result?.fromCache ?? false,
          emptyMessage:
              'No hay propuestas ni actividades confirmadas por revisar',
          onRefresh: _onRefresh,
          cardBuilder: _buildCard,
        );
      },
    );
  }
}
