import 'package:flutter/material.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';
import 'package:flutter_app/shared/widgets/local_data_banner.dart';

/// Lista de actividades que comparten las vistas de coordinación, revisión
/// financiera y balance: aviso de datos locales, deslizar para recargar,
/// estado vacío y un encabezado opcional (por ejemplo, filtros o resumen).
class ActivityListView extends StatelessWidget {
  final List<ItineraryActivity> items;
  final bool fromCache;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget Function(ItineraryActivity activity) cardBuilder;
  final Widget? header;

  const ActivityListView({
    super.key,
    required this.items,
    required this.fromCache,
    required this.emptyMessage,
    required this.onRefresh,
    required this.cardBuilder,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (fromCache) const LocalDataBanner(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: items.isEmpty ? _buildEmpty() : _buildList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    final children = <Widget>[];
    final headerWidget = header;
    if (headerWidget != null) {
      children.add(headerWidget);
    }
    children.add(const SizedBox(height: 48));
    children.add(EmptyView(message: emptyMessage));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Widget _buildList() {
    final headerWidget = header;
    // Si hay encabezado, ocupa la posición 0 y las tarjetas se corren una.
    final extra = headerWidget == null ? 0 : 1;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length + extra,
      itemBuilder: (context, index) {
        if (headerWidget != null && index == 0) {
          return headerWidget;
        }
        final activity = items[index - extra];
        return cardBuilder(activity);
      },
    );
  }
}
