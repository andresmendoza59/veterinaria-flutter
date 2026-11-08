import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_card.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_list_view.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/budget_summary_card.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/cost_dialog.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/decision_helpers.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/validators/activity_filters.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

/// Vista del responsable de presupuesto: aprueba o devuelve el costo previsto
/// de los horarios aprobados y registra el costo real de las realizadas.
/// Reservar y cerrar costos se hace online con transacciones de Firestore.
class FinanceReviewScreen extends StatefulWidget {
  final String uid;
  final UserRole role;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const FinanceReviewScreen({
    super.key,
    required this.uid,
    required this.role,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  State<FinanceReviewScreen> createState() => _FinanceReviewScreenState();
}

class _FinanceReviewScreenState extends State<FinanceReviewScreen> {
  late Future<ActivitiesResult> _future;
  // Último resumen calculado; se usa en los mensajes de los diálogos.
  BudgetSummary? _summary;

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

  String _availableText() {
    final summary = _summary;
    if (summary == null) return '';
    return 'Saldo disponible hoy: ${Fmt.money(summary.available)}.';
  }

  Future<void> _approveCost(ItineraryActivity activity) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Aprobar costo',
      message:
          'Se reservarán ${Fmt.money(activity.estimatedCost)} para '
          '"${activity.title}". ${_availableText()} '
          'Si el saldo no alcanza, la aprobación será rechazada.',
      confirmLabel: 'Aprobar y reservar',
    );
    if (!mounted) return;
    if (!confirmed) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.approveCost(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
      ),
      successMessage: 'Costo aprobado: la actividad quedó confirmada',
      refresh: widget.refresh,
    );
  }

  Future<void> _returnToProposal(ItineraryActivity activity) async {
    final reason = await reasonDialog(
      context,
      title: 'Rechazar costo y devolver a propuesta',
      confirmLabel: 'Devolver',
    );
    if (!mounted) return;
    if (reason == null) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.returnToProposal(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
        reason: reason,
      ),
      successMessage: 'Devuelta a propuesta: la franja quedó libre',
      refresh: widget.refresh,
    );
  }

  Future<void> _closeCost(ItineraryActivity activity) async {
    final realCost = await costDialog(
      context,
      title: 'Cerrar costo real',
      message:
          'Reservado: ${Fmt.money(activity.reservedCost)}. '
          'Escribe cuánto costó realmente "${activity.title}". '
          'Si supera la reserva, la diferencia debe caber en el saldo.',
      initialValue: activity.reservedCost,
    );
    if (!mounted) return;
    if (realCost == null) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.closeCost(
        id: activity.id,
        uid: widget.uid,
        role: widget.role,
        realCost: realCost,
      ),
      successMessage: 'Costo cerrado en ${Fmt.money(realCost)}',
      refresh: widget.refresh,
    );
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
    if (_can(ActivityAction.approveCost, activity)) {
      actions.add(
        FilledButton.icon(
          onPressed: () => _approveCost(activity),
          icon: const Icon(Icons.price_check),
          label: const Text('Aprobar costo'),
        ),
      );
    }
    if (_can(ActivityAction.returnToProposal, activity)) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => _returnToProposal(activity),
          icon: const Icon(Icons.undo),
          label: const Text('Rechazar costo'),
        ),
      );
    }
    if (_can(ActivityAction.closeCost, activity)) {
      actions.add(
        FilledButton.icon(
          onPressed: () => _closeCost(activity),
          icon: const Icon(Icons.receipt_long),
          label: const Text('Cerrar costo real'),
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
            message: 'No se pudo cargar la revisión financiera',
            retryLabel: 'Reintentar',
            onRetry: _reload,
          );
        }

        final result = snapshot.data;
        final all = result?.items ?? [];
        final summary = ItineraryRules.summarize(
          ActivityFilters.onlySynced(all),
        );
        _summary = summary;

        return ActivityListView(
          items: ActivityFilters.forFinance(all),
          fromCache: result?.fromCache ?? false,
          emptyMessage: 'No hay costos por aprobar ni por cerrar',
          onRefresh: _onRefresh,
          cardBuilder: _buildCard,
          header: BudgetSummaryCard(
            title: 'Presupuesto del viaje',
            summary: summary,
          ),
        );
      },
    );
  }
}
