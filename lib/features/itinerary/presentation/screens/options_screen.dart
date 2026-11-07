import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/option_detail_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/option_card.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';

class OptionsScreen extends StatefulWidget {
  final CatalogSource catalogSource;
  final String uid;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const OptionsScreen({
    super.key,
    required this.catalogSource,
    required this.uid,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late Future<List<CatalogActivity>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.catalogSource.fetchCatalog();
  }

  void _retry() {
    setState(() {
      _future = widget.catalogSource.fetchCatalog();
    });
  }

  String _friendlyError(Object? error) {
    if (error is CatalogException) {
      return error.toString();
    }
    return 'No se pudo cargar el catálogo';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CatalogActivity>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: _friendlyError(snapshot.error),
            retryLabel: 'Reintentar',
            onRetry: _retry,
          );
        }

        final options = snapshot.data ?? [];

        if (options.isEmpty) {
          return const EmptyView(message: 'No hay opciones disponibles por ahora');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];

            return OptionCard(
              option: option,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OptionDetailScreen(
                      option: option,
                      uid: widget.uid,
                      itineraryRepo: widget.itineraryRepo,
                      refresh: widget.refresh,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
