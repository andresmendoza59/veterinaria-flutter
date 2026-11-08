import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/catalog_repository.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/option_detail_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/option_card.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/shared/widgets/local_data_banner.dart';

class OptionsScreen extends StatefulWidget {
  final CatalogRepository catalogRepo;
  final String uid;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const OptionsScreen({
    super.key,
    required this.catalogRepo,
    required this.uid,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late Future<CatalogResult> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.catalogRepo.getOptions();
  }

  void _retry() {
    setState(() {
      _future = widget.catalogRepo.getOptions();
    });
  }

  Future<void> _onRefresh() async {
    _retry();
    try {
      await _future;
    } catch (_) {
      return;
    }
  }

  String _friendlyError(Object? error) {
    if (error is CatalogException) {
      return error.toString();
    }
    return 'No se pudo cargar el catálogo';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CatalogResult>(
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

        final result = snapshot.data;
        final options = result?.options ?? <CatalogActivity>[];

        if (options.isEmpty) {
          return const EmptyView(
            message: 'No hay opciones disponibles por ahora',
          );
        }

        return Column(
          children: [
            // Sin internet se muestra la última copia del catálogo guardada en Drift.
            if (result?.fromCache ?? false) const LocalDataBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildList(options),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(List<CatalogActivity> options) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
  }
}
