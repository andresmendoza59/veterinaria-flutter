import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/proposal_form_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_card.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/decision_helpers.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

class MyProposalsScreen extends StatefulWidget {
  final String uid;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const MyProposalsScreen({
    super.key,
    required this.uid,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  late Future<List<ItineraryActivity>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.itineraryRepo.getMine(widget.uid);
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
      _future = widget.itineraryRepo.getMine(widget.uid);
    });
  }

  Future<void> _onRefresh() async {
    var remoteFailed = false;
    try {
      await widget.itineraryRepo.refreshFromRemote();
    } catch (_) {
      remoteFailed = true;
    }
    if (!mounted) return;
    if (remoteFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar. Mostrando datos locales'),
        ),
      );
    }
    _reload();
    try {
      await _future;
    } catch (_) {
      return;
    }
  }

  void _edit(ItineraryActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposalFormScreen(
          uid: widget.uid,
          itineraryRepo: widget.itineraryRepo,
          refresh: widget.refresh,
          existing: activity,
        ),
      ),
    );
  }

  Future<void> _discard(ItineraryActivity activity) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Descartar propuesta',
      message:
          'Se eliminará "${activity.title}" de este dispositivo y no se '
          'enviará. ¿Deseas continuar?',
      confirmLabel: 'Descartar',
    );
    if (!mounted) return;
    if (!confirmed) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.discard(
        id: activity.id,
        uid: widget.uid,
      ),
      successMessage: 'Propuesta descartada',
      refresh: widget.refresh,
    );
  }

  Future<void> _requestReturn(ItineraryActivity activity) async {
    final reason = await reasonDialog(
      context,
      title: 'Solicitar devolución a propuesta',
      confirmLabel: 'Solicitar',
    );
    if (!mounted) return;
    if (reason == null) return;
    await runDecision(
      context,
      action: () => widget.itineraryRepo.requestReturn(
        id: activity.id,
        uid: widget.uid,
        role: UserRole.member,
        reason: reason,
      ),
      successMessage: 'Devolución solicitada',
      refresh: widget.refresh,
    );
  }

  List<Widget> _actionsFor(ItineraryActivity activity) {
    final now = DateTime.now();
    final canEdit = ItineraryRules.can(
      action: ActivityAction.edit,
      role: UserRole.member,
      uid: widget.uid,
      activity: activity,
      now: now,
    );
    final canReturn = ItineraryRules.can(
      action: ActivityAction.requestReturn,
      role: UserRole.member,
      uid: widget.uid,
      activity: activity,
      now: now,
    );

    return [
      if (canEdit)
        OutlinedButton.icon(
          onPressed: () => _edit(activity),
          icon: const Icon(Icons.edit_outlined),
          label: Text(
            activity.syncState == SyncState.rejected ? 'Corregir' : 'Editar',
          ),
        ),
      if (activity.syncState != SyncState.synced)
        TextButton.icon(
          onPressed: () => _discard(activity),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Descartar'),
        ),
      if (canReturn)
        OutlinedButton.icon(
          onPressed: () => _requestReturn(activity),
          icon: const Icon(Icons.undo),
          label: const Text('Solicitar devolución'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItineraryActivity>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: 'No se pudieron cargar tus propuestas',
            retryLabel: 'Reintentar',
            onRetry: _reload,
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                EmptyView(message: 'Aún no has propuesto actividades'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final activity = items[index];

              return ActivityCard(
                activity: activity,
                actions: _actionsFor(activity),
              );
            },
          ),
        );
      },
    );
  }
}
