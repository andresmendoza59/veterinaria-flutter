import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/proposal_form_screen.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';

class OptionDetailScreen extends StatelessWidget {
  final CatalogActivity option;
  final String uid;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;

  const OptionDetailScreen({
    super.key,
    required this.option,
    required this.uid,
    required this.itineraryRepo,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la opción'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(option.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.category_outlined, size: 18),
                label: Text(option.category),
              ),
              Chip(
                avatar: const Icon(Icons.place_outlined, size: 18),
                label: Text(option.location),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Costo estimado', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            Fmt.money(option.estimatedCost),
            style: theme.textTheme.headlineMedium,
          ),
          if (option.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Descripción', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(option.description, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProposalFormScreen(
                    option: option,
                    uid: uid,
                    itineraryRepo: itineraryRepo,
                    refresh: refresh,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_task),
            label: const Text('Proponer para el viaje'),
          ),
        ],
      ),
    );
  }
}
