import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';

class OptionCard extends StatelessWidget {
  final CatalogActivity option;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(option.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      option.location,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(option.category),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    Fmt.money(option.estimatedCost),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
