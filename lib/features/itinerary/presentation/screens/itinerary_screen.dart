import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/shared/widgets/local_data_banner.dart';
import 'package:flutter_app/validators/activity_filters.dart';

/// Itinerario del viaje: cada día con sus franjas de 2 horas.
/// Una franja aparece ocupada solo cuando el coordinador aprobó el horario.
class ItineraryScreen extends StatefulWidget {
  final String uid;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const ItineraryScreen({
    super.key,
    required this.uid,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  late Future<ActivitiesResult> _future;

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

  Widget _buildSlot(DateTime day, int hour, List<ItineraryActivity> items) {
    final slotStart = TripConfig.slotStart(day, hour);
    final activity = ActivityFilters.activityAt(items, slotStart);
    final slotText = Fmt.slotLabel(slotStart);

    if (activity == null) {
      return ListTile(
        dense: true,
        leading: const Icon(Icons.radio_button_unchecked),
        title: Text(slotText),
        subtitle: const Text('Libre'),
      );
    }

    return ListTile(
      dense: true,
      leading: const Icon(Icons.event_available),
      title: Text('$slotText · ${activity.title}'),
      subtitle: Text('${activity.status.label} · ${activity.location}'),
    );
  }

  Widget _buildDay(DateTime day, List<ItineraryActivity> items) {
    final slots = <Widget>[];
    for (final hour in TripConfig.slotStartHours) {
      slots.add(_buildSlot(day, hour, items));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                Fmt.date(day),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...slots,
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<ItineraryActivity> items) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyView(message: 'Aún no hay actividades con horario aprobado'),
        ],
      );
    }

    final days = TripConfig.days;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) => _buildDay(days[index], items),
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
            message: 'No se pudo cargar el itinerario',
            retryLabel: 'Reintentar',
            onRetry: _reload,
          );
        }

        final result = snapshot.data;
        final items = ActivityFilters.forItinerary(result?.items ?? []);

        return Column(
          children: [
            if (result?.fromCache ?? false) const LocalDataBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildBody(items),
              ),
            ),
          ],
        );
      },
    );
  }
}
